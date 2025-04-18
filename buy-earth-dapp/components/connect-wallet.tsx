"use client"

import { Button } from "@/components/ui/button"
import { Wallet } from "lucide-react"

interface ConnectWalletProps {
  onConnect: () => Promise<void>
  loading: boolean
}

export function ConnectWallet({ onConnect, loading }: ConnectWalletProps) {
  return (
    <Button onClick={onConnect} className="flex items-center gap-2" size="lg" disabled={loading}>
      {loading ? (
        <>
          <div className="animate-spin h-5 w-5 border-2 border-current border-t-transparent rounded-full"></div>
          Connecting...
        </>
      ) : (
        <>
          <Wallet className="h-5 w-5" />
          Connect Wallet
        </>
      )}
    </Button>
  )
}
