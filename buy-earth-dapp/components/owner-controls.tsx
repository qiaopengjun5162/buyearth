"use client"

import { useState } from "react"
import { ethers } from "ethers"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { useToast } from "@/hooks/use-toast"
import { Tabs, TabsContent, TabsItem, TabsList } from "@/components/ui/tabs"

interface OwnerControlsProps {
  contract: ethers.Contract | null
  onSuccess: (action: string, details: string) => void
}

export function OwnerControls({ contract, onSuccess }: OwnerControlsProps) {
  const [newOwner, setNewOwner] = useState("")
  const [withdrawAddress, setWithdrawAddress] = useState("")
  const [squareIndex, setSquareIndex] = useState("")
  const [squareColor, setSquareColor] = useState("#000000")
  const [loading, setLoading] = useState(false)
  const { toast } = useToast()

  const handleSetOwner = async () => {
    if (!contract || !ethers.isAddress(newOwner)) {
      toast({
        title: "Error",
        description: "Please enter a valid address",
        variant: "destructive",
      })
      return
    }

    try {
      setLoading(true)

      const tx = await contract.setOwner(newOwner)

      toast({
        title: "Transaction Submitted",
        description: "Please wait for confirmation...",
      })

      await tx.wait()

      toast({
        title: "Success!",
        description: `Ownership transferred to ${newOwner}`,
      })

      onSuccess("Transfer Ownership", `Transferred to ${newOwner.slice(0, 6)}...${newOwner.slice(-4)}`)
      setNewOwner("")
    } catch (error: any) {
      console.error("Error setting owner:", error)
      toast({
        title: "Transaction Failed",
        description: error.message || "An error occurred while setting the owner",
        variant: "destructive",
      })
    } finally {
      setLoading(false)
    }
  }

  const handleWithdraw = async () => {
    if (!contract || !ethers.isAddress(withdrawAddress)) {
      toast({
        title: "Error",
        description: "Please enter a valid address",
        variant: "destructive",
      })
      return
    }

    try {
      setLoading(true)

      const tx = await contract.withdrawTo(withdrawAddress)

      toast({
        title: "Transaction Submitted",
        description: "Please wait for confirmation...",
      })

      await tx.wait()

      toast({
        title: "Success!",
        description: `Funds withdrawn to ${withdrawAddress}`,
      })

      onSuccess("Withdraw", `Funds withdrawn to ${withdrawAddress.slice(0, 6)}...${withdrawAddress.slice(-4)}`)
      setWithdrawAddress("")
    } catch (error: any) {
      console.error("Error withdrawing:", error)
      toast({
        title: "Transaction Failed",
        description: error.message || "An error occurred while withdrawing",
        variant: "destructive",
      })
    } finally {
      setLoading(false)
    }
  }

  const handleSetColor = async () => {
    if (!contract || !squareIndex || Number.parseInt(squareIndex) < 0 || Number.parseInt(squareIndex) > 99) {
      toast({
        title: "Error",
        description: "Please enter a valid square index (0-99)",
        variant: "destructive",
      })
      return
    }

    try {
      setLoading(true)

      // Convert hex color to number
      const colorNumber = Number.parseInt(squareColor.replace("#", ""), 16)
      const squareIdx = Number.parseInt(squareIndex)

      const tx = await contract.setColor(squareIdx, colorNumber)

      toast({
        title: "Transaction Submitted",
        description: "Please wait for confirmation...",
      })

      await tx.wait()

      toast({
        title: "Success!",
        description: `Color set for square #${squareIndex}`,
      })

      onSuccess("Set Color", `Changed color of square #${squareIndex}`)
      setSquareIndex("")
    } catch (error: any) {
      console.error("Error setting color:", error)
      toast({
        title: "Transaction Failed",
        description: error.message || "An error occurred while setting the color",
        variant: "destructive",
      })
    } finally {
      setLoading(false)
    }
  }

  return (
    <Tabs defaultValue="setColor">
      <TabsList className="grid grid-cols-3 mb-4">
        <TabsItem value="setColor">Set Color</TabsItem>
        <TabsItem value="withdraw">Withdraw</TabsItem>
        <TabsItem value="setOwner">Set Owner</TabsItem>
      </TabsList>

      <TabsContent value="setColor" className="space-y-4">
        <div>
          <Label htmlFor="squareIndex">Square Index (0-99)</Label>
          <Input
            id="squareIndex"
            type="number"
            min="0"
            max="99"
            value={squareIndex}
            onChange={(e) => setSquareIndex(e.target.value)}
            placeholder="0"
          />
        </div>

        <div>
          <Label htmlFor="squareColor">Choose Color</Label>
          <div className="flex gap-2">
            <Input
              type="color"
              id="squareColor"
              value={squareColor}
              onChange={(e) => setSquareColor(e.target.value)}
              className="w-16 h-10 p-1"
            />
            <Input
              type="text"
              value={squareColor}
              onChange={(e) => setSquareColor(e.target.value)}
              className="flex-1"
            />
          </div>
        </div>

        <Button onClick={handleSetColor} disabled={loading} className="w-full">
          {loading ? (
            <>
              <div className="animate-spin h-4 w-4 border-2 border-current border-t-transparent rounded-full mr-2"></div>
              Processing...
            </>
          ) : (
            "Set Color"
          )}
        </Button>
      </TabsContent>

      <TabsContent value="withdraw" className="space-y-4">
        <div>
          <Label htmlFor="withdrawAddress">Recipient Address</Label>
          <Input
            id="withdrawAddress"
            value={withdrawAddress}
            onChange={(e) => setWithdrawAddress(e.target.value)}
            placeholder="0x..."
          />
        </div>

        <Button onClick={handleWithdraw} disabled={loading} className="w-full" variant="destructive">
          {loading ? (
            <>
              <div className="animate-spin h-4 w-4 border-2 border-current border-t-transparent rounded-full mr-2"></div>
              Processing...
            </>
          ) : (
            "Withdraw All Funds"
          )}
        </Button>
      </TabsContent>

      <TabsContent value="setOwner" className="space-y-4">
        <div>
          <Label htmlFor="newOwner">New Owner Address</Label>
          <Input id="newOwner" value={newOwner} onChange={(e) => setNewOwner(e.target.value)} placeholder="0x..." />
        </div>

        <Button onClick={handleSetOwner} disabled={loading} className="w-full" variant="outline">
          {loading ? (
            <>
              <div className="animate-spin h-4 w-4 border-2 border-current border-t-transparent rounded-full mr-2"></div>
              Processing...
            </>
          ) : (
            "Transfer Ownership"
          )}
        </Button>
      </TabsContent>
    </Tabs>
  )
}
