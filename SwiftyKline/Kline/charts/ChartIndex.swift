//
//  ChartIndex.swift
//  AppCommon
//
//  Created by Kevin Wu on 2022/1/1.
//

import UIKit

func index_buffer(_ size: Int) -> (Double)->[Double] {
  var queue: [Double] = []
  let er: (Double)->[Double] = {
    queue.append($0)
    if queue.count > size {
      queue.removeFirst()
    }
    return queue
  }
  return er
}


func index_timeline(_ inputs: [[Double]]) -> [Int:[Double]] {
  inputs.dictValue
}

func index_range(_ inputs: [[Double]]) -> [Int:[Double]] {
  inputs.dictValue
}


// https://www.omnicalculator.com/finance/moving-average
// [1,2,3,4,5,6,7,8,9] 5
// [        3,4,5,6,7]
//
// let list: [Double] = [1,2,3,4,5,6,7,8,9]
// let inputs = list.map { [$0] }
// let result = index_ma(inputs, 5)
// let res = result
//   .map { [$0.key.dbl, $0.value[0]] }
//   .sorted { $0[0] < $1[0] }
// print( res )
func index_ma(_ inputs: [[Double]], _ period: Int) -> [Int:[Double]] {
  let input: (Int)->Double = { inputs[$0][0] }
  let count = inputs.count

  var ret: [Int:[Double]] = [:]

  var sum = 0.0
  for i in 0..<count {
    if i < period-1 {
      sum += input(i)
    } else if i == period-1 {
      sum += input(i)
      let ma = sum / period.dbl
      ret[i] = [ma]
    } else {
      sum -= input(i-period)
      sum += input(i)
      let ma = sum / period.dbl
      ret[i] = [ma]
    }
  }

  return ret
}

// https://tulipindicators.org/ema
// https://www.statology.org/excel-exponential-moving-average/
// [25, 20, 14, 16, 27, 20, 12, 15, 14, 19] 3
// [25, 22.5, 18.25, 17.13, 22.06, 21.03, 16.52, 15.76, 14.88, 16.94]
func index_ema(_ inputs: [[Double]], _ period: Int) -> [Int:[Double]] {
  let input: (Int)->Double = { inputs[$0][0] }
  let count = inputs.count

  var ret: [Int:[Double]] = [:]

  let per = 2 / (period + 1).dbl

  var ema = 0.0
  for i in 0..<count {
    if i == 0 {
      ema = input(0)
    } else {
      ema = (input(i) - ema) * per + ema
    }
    ret[i] = [ema]
  }

  return ret
}

// https://www.investopedia.com/terms/b/bollingerbands.asp
func index_boll(_ inputs: [[Double]], _ period: Int, _ deviations: Double) -> [Int:[Double]] {
  let input: (Int)->Double = { inputs[$0][0] }
  let count = inputs.count

  var ret: [Int:[Double]] = [:]

  let ma_buf = index_buffer(period)

  for i in 0..<count {
    let mas = ma_buf(input(i))
    if i >= period-1 {
      let ma = mas.reduce(0, +) / period.dbl

      var sum = 0.0
      for j in (i+1-period)..<(i+1) {
        sum += pow(input(j) - ma, 2)
      }
      let sd = sqrt(sum / period.dbl)

      let mid = ma
      let up = mid + deviations * sd
      let low = mid - deviations * sd

      ret[i] = [mid, up, low]
    }
  }

  return ret
}


func index_vol(_ inputs: [[Double]]) -> [Int:[Double]] {
  inputs.dictValue
}

// https://tulipindicators.org/macd
//
// https://medium.com/duedex/what-is-macd-4a43050e2ca8
// The DIF line is called the MACD line
// The DEA line is called the Signal line
// Histogram usually drawn as a bar chart
//
// https://www.fmlabs.com/reference/default.htm?url=MACD.htm
// why 0.15 & 0.075 ?
func index_macd(_ inputs: [[Double]], _ short_period: Int, _ long_period: Int, _ signal_period: Int) -> [Int:[Double]] {
  let input: (Int)->Double = { inputs[$0][0] }
  let count = inputs.count

  var ret: [Int:[Double]] = [:]

  var short_per = 2 / (short_period + 1).dbl
  var long_per = 2 / (long_period + 1).dbl
  let signal_per = 2 / (signal_period + 1).dbl

  if short_period == 12 && long_period == 26 {
    // I don't like this, but it's what people expect.
    short_per = 0.15
    long_per = 0.075
  }

  var short_ema = 0.0
  var long_ema = 0.0
  var signal_ema = 0.0
  for i in 0..<count {
    if i == 0 {
      short_ema = input(0)
      long_ema = input(0)
    } else {
      short_ema = (input(i) - short_ema) * short_per + short_ema
      long_ema = (input(i) - long_ema) * long_per + long_ema
      let out = short_ema - long_ema
      if i == long_period-1 {
        signal_ema = out
      }
      if i >= long_period-1 {
        signal_ema = (out - signal_ema) * signal_per + signal_ema
        let macd = out
        let signal = signal_ema
        let hist = out - signal_ema
        ret[i] = [macd, signal, hist]
      }
    }
  }

  return ret
}

// https://tulipindicators.org/stoch
func index_kdj(_ inputs: [[Double]], _ kperiod: Int, _ kslow: Int, _ dperiod: Int) -> [Int:[Double]] {
  let high: (Int)->Double = { inputs[$0][0] }
  let low: (Int)->Double = { inputs[$0][1] }
  let close: (Int)->Double = { inputs[$0][2] }
  let count = inputs.count

  var ret: [Int:[Double]] = [:]

  let kper = 1 / kslow.dbl
  let dper = 1 / dperiod.dbl

  let max_buf = index_buffer(kperiod)
  let min_buf = index_buffer(kperiod)
  let kfast_buf = index_buffer(kslow)
  let k_buf = index_buffer(dperiod)

  for i in 0..<count {
    let maxs = max_buf(high(i))
    let mins = min_buf(low(i))
    // 0...8, 9 max/min enqueue, then go inside

    if i >= kperiod-1 {
      let max = maxs.max() ?? 0
      let min = mins.min() ?? 0
      let kdiff = max - min
      let kfast = kdiff == 0 ? 0 : 100 * ((close(i) - min) / kdiff)
      let kfasts = kfast_buf(kfast)
      // 8...10, 3 kfast enqueue, then go inside

      if i >= kperiod-1 + kslow-1 {
        let k = kfasts.reduce(0, +) * kper
        let ks = k_buf(k)
        // 10...12, 3 k enqueue, then go inside

        if i >= kperiod-1 + kslow-1 + dperiod-1 {
          let d = ks.reduce(0, +) * dper

          // I don't know what does 3 and 2 means. Maybe people think 9,3,3 is fix parameters and won't change in the future.
          // So they said j value formula is `k * 3 - d * 2`.
          let j = k * 3 - d * 2
          ret[i] = [k, d, j]
        }
      }
    }
  }

  return ret
}

// https://www.omnicalculator.com/finance/rsi
func index_rsi(_ inputs: [[Double]], _ period: Int) -> [Int:[Double]] {
  let input: (Int)->Double = { inputs[$0][0] }
  let count = inputs.count

  var ret: [Int:[Double]] = [:]

  let upward_buf = index_buffer(period)
  let downward_buf = index_buffer(period)
  for i in 1..<count {
    let upward = input(i) > input(i-1) ? input(i) - input(i-1) : 0
    let downward = input(i) < input(i-1) ? input(i-1) - input(i) : 0
    let upwards = upward_buf(upward)
    let downwards = downward_buf(downward)
    if i >= period {
      let up_smooth = upwards.reduce(0, +) / period.dbl
      let down_smooth = downwards.reduce(0, +) / period.dbl
      let rsi = 100 - 100 / (1 + up_smooth / down_smooth)
      ret[i] = [rsi]
    }
  }

  return ret
}
