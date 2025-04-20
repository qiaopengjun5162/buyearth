"use client"

import { useState, useEffect } from "react"
import { ethers } from "ethers"
import { ConnectWallet } from "@/components/connect-wallet"
import { Grid } from "@/components/grid"
import { BuySquareForm } from "@/components/buy-square-form"
import { DepositForm } from "@/components/deposit-form"
import { OwnerControls } from "@/components/owner-controls"
import { contractABI } from "@/lib/contract-abi"
import { Tabs, TabsContent, TabsItem, TabsList } from "@/components/ui/tabs"
import { Button } from "@/components/ui/button"
import { LogOut, RefreshCw } from "lucide-react"
import { TransactionHistory } from "@/components/transaction-history"
import { NetworkStatus } from "@/components/network-status"
import { useToast } from "@/hooks/use-toast"

declare global {
  interface Window {
    ethereum: any;
  }
}


export default function Home() {
  const [provider, setProvider] = useState<ethers.BrowserProvider | null>(null)
  const [signer, setSigner] = useState<ethers.Signer | null>(null)
  const [contract, setContract] = useState<ethers.Contract | null>(null)
  const [account, setAccount] = useState<string>("")
  const [isOwner, setIsOwner] = useState(false)
  const [squares, setSquares] = useState<number[]>(Array(100).fill(0))
  const [selectedSquare, setSelectedSquare] = useState<number | null>(null)
  const [contractOwner, setContractOwner] = useState<string>("")
  const [userDeposit, setUserDeposit] = useState<string>("0")
  const [loading, setLoading] = useState(true)
  const [networkName, setNetworkName] = useState<string>("")
  const [transactions, setTransactions] = useState<any[]>([])
  const { toast } = useToast()

  const contractAddress = "0xcA7EC1c665C252067e2CfbE55E40Aa29777A1B7E" // Replace with actual contract address

  // Check if wallet was previously connected
  useEffect(() => {
    const checkConnection = async () => {
      if (window.ethereum && window.localStorage.getItem("walletConnected") === "true") {
        connectWallet()
      } else {
        setLoading(false)
      }
    }

    checkConnection()
  }, [])

  // Listen for account changes
  useEffect(() => {
    if (window.ethereum) {
      window.ethereum.on("accountsChanged", handleAccountsChanged)
      window.ethereum.on("chainChanged", handleChainChanged)
    }

    return () => {
      if (window.ethereum) {
        window.ethereum.removeListener("accountsChanged", handleAccountsChanged)
        window.ethereum.removeListener("chainChanged", handleChainChanged)
      }
    }
  }, [])

  // Load contract data when account or contract changes
  useEffect(() => {
    if (account && contract) {
      loadContractData()
    }
  }, [account, contract])

  const handleAccountsChanged = (accounts: string[]) => {
    if (accounts.length === 0) {
      // User disconnected their wallet
      disconnectWallet()
    } else if (accounts[0] !== account) {
      // User switched accounts
      setAccount(accounts[0])
      toast({
        title: "Account Changed",
        description: `Switched to account: ${accounts[0].slice(0, 6)}...${accounts[0].slice(-4)}`,
      })
    }
  }

  const handleChainChanged = () => {
    // When chain changes, we need to reload the page to get the new chain's provider
    window.location.reload()
  }

  const connectWallet = async () => {
    try {
      setLoading(true)
      if (window.ethereum) {
        const provider = new ethers.BrowserProvider(window.ethereum)
        const network = await provider.getNetwork()
        setNetworkName(network.name)

        const signer = await provider.getSigner()
        console.log("Signer:", signer)
        const contract = new ethers.Contract(contractAddress, contractABI, signer)
        const accounts = await provider.send("eth_requestAccounts", [])

        setProvider(provider)
        setSigner(signer)
        setContract(contract)
        setAccount(accounts[0])

        // Save connection state
        window.localStorage.setItem("walletConnected", "true")

        toast({
          title: "Wallet Connected",
          description: `Connected to ${accounts[0].slice(0, 6)}...${accounts[0].slice(-4)}`,
        })
      } else {
        toast({
          title: "MetaMask Required",
          description: "Please install MetaMask to use this application",
          variant: "destructive",
        })
      }
    } catch (error: any) {
      console.error("Error connecting wallet:", error)
      toast({
        title: "Connection Failed",
        description: error.message || "Failed to connect wallet",
        variant: "destructive",
      })
    } finally {
      setLoading(false)
    }
  }

  const disconnectWallet = () => {
    setProvider(null)
    setSigner(null)
    setContract(null)
    setAccount("")
    setIsOwner(false)
    setUserDeposit("0")
    window.localStorage.removeItem("walletConnected")
    toast({
      title: "Wallet Disconnected",
      description: "Your wallet has been disconnected",
    })
  }

  const loadContractData = async () => {
    if (!contract) return

    try {
      setLoading(true)

      // Get squares data
      const squaresData = await contract.getSquares()
      setSquares(squaresData.map((color: ethers.BigNumberish) => Number(color)))

      // Get owner
      const owner = await contract.getOwner()
      setContractOwner(owner)
      setIsOwner(account.toLowerCase() === owner.toLowerCase())

      // Get user deposit
      if (account) {
        const deposit = await contract.getUserDeposits(account)
        setUserDeposit(ethers.formatEther(deposit))
      }

      setLoading(false)
    } catch (error: any) {
      console.error("Error loading contract data:", error)
      toast({
        title: "Data Loading Failed",
        description: error.message || "Failed to load contract data",
        variant: "destructive",
      })
      setLoading(false)
    }
  }

  const handleSquareClick = (index: number) => {
    setSelectedSquare(index)
  }

  const addTransaction = (type: string, details: string) => {
    const newTransaction = {
      id: Date.now(),
      type,
      details,
      timestamp: new Date().toLocaleString(),
    }
    setTransactions((prev) => [newTransaction, ...prev].slice(0, 10)) // Keep only the last 10 transactions
  }

  return (
    <main className="flex min-h-screen flex-col items-center p-4 md:p-8 bg-gray-50">
      <div className="w-full max-w-6xl">
        <div className="flex justify-between items-center mb-8">
          <h1 className="text-4xl font-bold">Buy Earth</h1>

          {account ? (
            <div className="flex items-center gap-2">
              <NetworkStatus networkName={networkName} />
              <Button variant="outline" size="sm" onClick={loadContractData} className="flex items-center gap-1">
                <RefreshCw className="h-4 w-4" />
                <span className="hidden sm:inline">Refresh</span>
              </Button>
              <Button variant="outline" size="sm" onClick={disconnectWallet} className="flex items-center gap-1">
                <LogOut className="h-4 w-4" />
                <span className="hidden sm:inline">Disconnect</span>
              </Button>
            </div>
          ) : null}
        </div>

        {!account ? (
          <div className="flex flex-col items-center justify-center p-8 bg-white rounded-lg shadow-md">
            <h2 className="text-2xl font-semibold mb-4">Connect your wallet to get started</h2>
            <ConnectWallet onConnect={connectWallet} loading={loading} />
          </div>
        ) : (
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
            <div className="lg:col-span-2">
              <div className="bg-white p-6 rounded-lg shadow-md mb-8">
                <h2 className="text-2xl font-semibold mb-4">Earth Grid</h2>
                {loading ? (
                  <div className="flex justify-center items-center h-[500px]">
                    <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-gray-900"></div>
                  </div>
                ) : (
                  <Grid squares={squares} onSquareClick={handleSquareClick} selectedSquare={selectedSquare} />
                )}
              </div>

              <div className="bg-white p-6 rounded-lg shadow-md">
                <h2 className="text-xl font-semibold mb-4">Transaction History</h2>
                <TransactionHistory transactions={transactions} />
              </div>
            </div>

            <div className="lg:col-span-1">
              <div className="bg-white p-6 rounded-lg shadow-md mb-8">
                <h2 className="text-xl font-semibold mb-4">Account Info</h2>
                <p className="mb-2">
                  <span className="font-medium">Address:</span> {account.slice(0, 6)}...{account.slice(-4)}
                </p>
                <p className="mb-4">
                  <span className="font-medium">Deposit:</span> {userDeposit} ETH
                </p>
                <p className="mb-2">
                  <span className="font-medium">Contract Owner:</span> {contractOwner.slice(0, 6)}...
                  {contractOwner.slice(-4)}
                </p>
                {isOwner && <p className="text-green-600 font-medium">You are the owner</p>}
              </div>

              <div className="bg-white p-6 rounded-lg shadow-md">
                <Tabs defaultValue="buy">
                  <TabsList className="grid grid-cols-2 mb-4">
                    <TabsItem value="buy">Buy Square</TabsItem>
                    <TabsItem value="deposit">Deposit</TabsItem>
                  </TabsList>

                  <TabsContent value="buy">
                    <BuySquareForm
                      contract={contract}
                      selectedSquare={selectedSquare}
                      onSuccess={() => {
                        loadContractData()
                        addTransaction("Buy", `Purchased square #${selectedSquare}`)
                      }}
                    />
                  </TabsContent>

                  <TabsContent value="deposit">
                    <DepositForm
                      contract={contract}
                      onSuccess={(amount) => {
                        loadContractData()
                        addTransaction("Deposit", `Deposited ${amount} ETH`)
                      }}
                    />
                  </TabsContent>
                </Tabs>
              </div>

              {isOwner && (
                <div className="bg-white p-6 rounded-lg shadow-md mt-8">
                  <h2 className="text-xl font-semibold mb-4">Owner Controls</h2>
                  <OwnerControls
                    contract={contract}
                    onSuccess={(action, details) => {
                      loadContractData()
                      addTransaction(action, details)
                    }}
                  />
                </div>
              )}
            </div>
          </div>
        )}
      </div>
    </main>
  )
}
