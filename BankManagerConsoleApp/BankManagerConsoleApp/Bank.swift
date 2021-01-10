
import Foundation

class Bank {
    private var bankClerkNumber: Int
    private var waitingList: [Client] = []
    private var totalProcessedClientsNumber: Int = 0
    private var totalOperateTime: Double = 0
    private var startTime: TimeInterval = 0
    
    var endingMent: String {
        return "업무가 마감되었습니다. 오늘 업무를 처리한 고객은 총 \(totalProcessedClientsNumber)명이며, 총 업무시간은 \(totalOperateTime)초입니다."
    }
    
    init(employeeNumber: Int) {
        self.bankClerkNumber = employeeNumber
    }

    func updateWaitingList(of size: Int) throws {
        guard size > 0 else {
            throw BankOperationError.invalidValue
        }

        for i in  1...size {
            let newClient = Client(waitingNumber: i, business: .deposit, grade: .VIP)
            waitingList.append(newClient)
        }
    }
    
    func makeAllClerksWork() {
        let semaphore = DispatchSemaphore(value: 1)
        let counterGroup = DispatchGroup()
        
        for i in 1...bankClerkNumber {
            let dispatchQueue = DispatchQueue(label: "Counter\(i)Queue", attributes: .concurrent)
        
            dispatchQueue.async(group: counterGroup) {
                self.handleWaitingList(with: semaphore)
            }
        }
        
        counterGroup.wait()
    }
    
    
    private func handleWaitingList(with semaphore: DispatchSemaphore) {
        let bankClerk = BankClerk()

        while !self.waitingList.isEmpty {
            semaphore.wait()
            guard let client = self.waitingList.first else {
                return
            }
            self.waitingList.removeFirst()
            semaphore.signal()
            
            bankClerk.handleClientBusiness(of: client)
            self.totalProcessedClientsNumber += 1
        }
    }
}

// MARK: Timer
extension Bank {
    func startTimer() {
        startTime = Date.timeIntervalSinceReferenceDate
    }

    func stopTimer() {
        let currentTime = Date.timeIntervalSinceReferenceDate
        let timeDiferrence = currentTime - startTime
        
        totalOperateTime = roundToSecondDecimalPlace(number: timeDiferrence)
    }
    
    private func roundToSecondDecimalPlace(number: Double) -> Double {
        let newNumber = number * 100
        let result = round(newNumber) / 100
        return result
    }
}
