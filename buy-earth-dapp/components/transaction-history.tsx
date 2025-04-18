"use client"

import { ScrollArea } from "@/components/ui/scroll-area"
import { Clock, CreditCard, Download, Upload, Palette } from "lucide-react"

interface Transaction {
  id: number
  type: string
  details: string
  timestamp: string
}

interface TransactionHistoryProps {
  transactions: Transaction[]
}

export function TransactionHistory({ transactions }: TransactionHistoryProps) {
  const getIcon = (type: string) => {
    switch (type.toLowerCase()) {
      case "buy":
        return <CreditCard className="h-4 w-4 text-blue-500" />
      case "deposit":
        return <Download className="h-4 w-4 text-green-500" />
      case "withdraw":
        return <Upload className="h-4 w-4 text-red-500" />
      case "set color":
        return <Palette className="h-4 w-4 text-purple-500" />
      case "transfer ownership":
        return <CreditCard className="h-4 w-4 text-orange-500" />
      default:
        return <Clock className="h-4 w-4 text-gray-500" />
    }
  }

  return (
    <div className="border rounded-md">
      {transactions.length === 0 ? (
        <div className="p-4 text-center text-gray-500">No transactions yet</div>
      ) : (
        <ScrollArea className="h-[200px]">
          <div className="divide-y">
            {transactions.map((tx) => (
              <div key={tx.id} className="flex items-start p-3 hover:bg-gray-50">
                <div className="mr-3 mt-0.5">{getIcon(tx.type)}</div>
                <div className="flex-1">
                  <div className="flex justify-between items-start">
                    <p className="font-medium">{tx.type}</p>
                    <span className="text-xs text-gray-500">{tx.timestamp}</span>
                  </div>
                  <p className="text-sm text-gray-600">{tx.details}</p>
                </div>
              </div>
            ))}
          </div>
        </ScrollArea>
      )}
    </div>
  )
}
