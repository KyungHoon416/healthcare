//인솔부분 음성 나오는 기능 넣기
//사용자가 발걸음을 걸었을 때 보정을 하기 위해서 얼마나 치우셨는지 확인하는 코드
if self?.viewModel.feedbackType == 1 {
    //기준점을 도와주는 함수                    
    var tmp : Float = Float((self!.viewModel.feedbackValue - Float(cadence))/self!.viewModel.feedbackValue * 100.0)
    var val1 = (self?.viewModel.feedbackValue)!
    var val2 = abs(tmp)
    if tmp > 3 { //slow
       self?.feedoneMinLabel.text = String.init(format: "%d".localized(), cadence)
       self?.feedbackoneMinLabel.text = String.init(format: "feedback_cadence_case3".localized(), val2) // 케이스3 왼쪽 발이 더 치우친 상황
     }else if tmp < -3 {
         self?.feedoneMinLabel.text = String.init(format: "%d".localized(), cadence)
         self?.feedbackoneMinLabel.text = String.init(format: "feedback_cadence_case2".localized(),  val2) // 케이스2 오른발이 더 치우친 상황
      }else {
           self?.feedoneMinLabel.text = String.init(format: "%d".localized(), cadence)
           self?.feedbackoneMinLabel.text = String.init(format: "feedback_cadence_case1".localized()) // 케이스1 양쪽발이 군형이 맞춘 상황
      }
                        
                    }





func onSensorReceived(_ sensorData: SensorData) {
    self.recordingSensorDatas.append(sensorData)
    self.recordingSensorCount += 1


    let startFeedback = (feedbackCurrentTime >= 60*1) ? true : false
    
    if self.isLongGaitActivity && (self.recordingSensorCount == 24000 || startFeedback ){
        let duplicateArray = NSArray(array:recordingSensorDatas, copyItems: true)
        recordingSensorCount = 0
        recordingSensorDatas.removeAll()

        if startFeedback {
            feedbackCurrentTime = 0
            feedbackProgress += 1
        }


        print("Need processing sensor")
        DispatchQueue.global(qos: .background).async {
            self.processingSensor(sensors:duplicateArray as! [SensorData], completionHandler: {

                if self.feedbackProgress != 0 {
                    var one_min_analysis = GaitProperty()
                    if self.feedbackAnalysisData.last != nil {
                        one_min_analysis = self.getAvgGaitAnalysisReport(gaitList: [self.feedbackAnalysisData.last!])

                        self.feedbackAnalysisDataResult.append(one_min_analysis)
                        self.onOneFeedbackStart?(one_min_analysis)
                    }

                    if self.feedbackProgress >= 5 {

                        self.feedbackProgress = 0

                        if self.feedbackEnabled {

                            var repo = GaitProperty()
                            if self.feedbackAnalysisData.count > 0 {
                                repo = self.getAvgGaitAnalysisReport(gaitList: self.feedbackAnalysisData)
                            }

                            self.feedbackAnalysisData.removeAll()
                            self.onFeedbackStart?(repo)
                            self.onOneFeedbackStart?(one_min_analysis)
                        }

}

                }

            })
        }
    }
}