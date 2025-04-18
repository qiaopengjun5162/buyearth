"use client"

import { useState } from "react"
import { ethers } from "ethers"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { useToast } from "@/hooks/use-toast"

interface DepositFormProps {
  contract: ethers.Contract | null
  onSuccess: (amount: string) => void
}

export function DepositForm({ contract, onSuccess }: DepositFormProps) {
  const [amount, setAmount] = useState("")
  const [loading, setLoading] = useState(false)
  const { toast } = useToast()

  const handleDeposit = async () => {
    if (!contract || !amount || Number.parseFloat(amount) <= 0) {
      toast({
        title: "Error",
        description: "Please enter a valid amount",
        variant: "destructive",
      })
      return
    }

    try {
      setLoading(true)

      // Call contract function
      const tx = await contract.deposit({
        value: ethers.parseEther(amount),
      })

      toast({
        title: "Transaction Submitted",
        description: "Please wait for confirmation...",
      })

      await tx.wait()

      toast({
        title: "Success!",
        description: `You've successfully deposited ${amount} ETH`,
      })

      onSuccess(amount)
      setAmount("")
    } catch (error: any) {
      console.error("Error depositing:", error)
      toast({
        title: "Transaction Failed",
        description: error.message || "An error occurred while depositing",
        variant: "destructive",
      })
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="space-y-4">
      <div>
        <Label htmlFor="amount">Amount (ETH)</Label>
        <Input
          id="amount"
          type="number"
          step="0.001"
          min="0.001"
          value={amount}
          onChange={(e) => setAmount(e.target.value)}
          placeholder="0.01"
        />
      </div>

      <div className="pt-2">
        <Button
          onClick={handleDeposit}
          disabled={loading || !amount || Number.parseFloat(amount) <= 0}
          className="w-full"
        >
          {loading ? (
            <>
              <div className="animate-spin h-4 w-4 border-2 border-current border-t-transparent rounded-full mr-2"></div>
              Processing...
            </>
          ) : (
            "Deposit ETH"
          )}
        </Button>
      </div>
    </div>
  )
}
