"use client"

import { useState } from "react"
import { ethers } from "ethers"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { useToast } from "@/hooks/use-toast"

interface BuySquareFormProps {
  contract: ethers.Contract | null
  selectedSquare: number | null
  onSuccess: () => void
}

export function BuySquareForm({ contract, selectedSquare, onSuccess }: BuySquareFormProps) {
  const [color, setColor] = useState("#000000")
  const [loading, setLoading] = useState(false)
  const { toast } = useToast()

  const handleBuySquare = async () => {
    if (!contract || selectedSquare === null) {
      toast({
        title: "Error",
        description: "Please select a square first",
        variant: "destructive",
      })
      return
    }

    try {
      setLoading(true)

      // Convert hex color to number
      const colorNumber = Number.parseInt(color.replace("#", ""), 16)

      // Call contract function
      const tx = await contract.buySquare(selectedSquare, colorNumber, {
        value: ethers.parseEther("0.001"),
      })

      toast({
        title: "Transaction Submitted",
        description: "Please wait for confirmation...",
      })

      await tx.wait()

      toast({
        title: "Success!",
        description: `You've successfully purchased square #${selectedSquare}`,
      })

      onSuccess()
    } catch (error: any) {
      console.error("Error buying square:", error)
      toast({
        title: "Transaction Failed",
        description: error.message || "An error occurred while buying the square",
        variant: "destructive",
      })
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="space-y-4">
      <div>
        <Label htmlFor="square">Selected Square</Label>
        <Input
          id="square"
          value={selectedSquare !== null ? selectedSquare : ""}
          readOnly
          placeholder="Click on a square to select it"
        />
      </div>

      <div>
        <Label htmlFor="color">Choose Color</Label>
        <div className="flex gap-2">
          <Input
            type="color"
            id="color"
            value={color}
            onChange={(e) => setColor(e.target.value)}
            className="w-16 h-10 p-1"
          />
          <Input type="text" value={color} onChange={(e) => setColor(e.target.value)} className="flex-1" />
        </div>
      </div>

      <div className="pt-2">
        <Button onClick={handleBuySquare} disabled={loading || selectedSquare === null} className="w-full">
          {loading ? (
            <>
              <div className="animate-spin h-4 w-4 border-2 border-current border-t-transparent rounded-full mr-2"></div>
              Processing...
            </>
          ) : (
            "Buy Square for 0.001 ETH"
          )}
        </Button>
      </div>

      <p className="text-sm text-gray-500 mt-2">Price: 0.001 ETH per square</p>
    </div>
  )
}
