"use client"

import { Badge } from "@/components/ui/badge"
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from "@/components/ui/tooltip"
import { Wifi } from "lucide-react"

interface NetworkStatusProps {
  networkName: string
}

export function NetworkStatus({ networkName }: NetworkStatusProps) {
  const getNetworkColor = (network: string): string => {
    const networkLower = network.toLowerCase()
    if (networkLower === "mainnet" || networkLower === "homestead") return "green"
    if (networkLower.includes("goerli")) return "yellow"
    if (networkLower.includes("sepolia")) return "purple"
    if (networkLower.includes("mumbai")) return "blue"
    if (networkLower.includes("polygon")) return "indigo"
    return "gray"
  }

  const color = getNetworkColor(networkName)
  const displayName = networkName === "homestead" ? "Ethereum Mainnet" : networkName

  return (
    <TooltipProvider>
      <Tooltip>
        <TooltipTrigger asChild>
          <Badge
            variant="outline"
            className={`bg-${color}-50 text-${color}-700 border-${color}-200 flex items-center gap-1`}
          >
            <Wifi className="h-3 w-3" />
            <span className="capitalize">{displayName || "Unknown Network"}</span>
          </Badge>
        </TooltipTrigger>
        <TooltipContent>
          <p>Connected Network</p>
        </TooltipContent>
      </Tooltip>
    </TooltipProvider>
  )
}
