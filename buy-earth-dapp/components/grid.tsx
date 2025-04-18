"use client"

import { useState } from "react"

interface GridProps {
  squares: number[]
  onSquareClick: (index: number) => void
  selectedSquare: number | null
}

export function Grid({ squares, onSquareClick, selectedSquare }: GridProps) {
  const [hoveredSquare, setHoveredSquare] = useState<number | null>(null)

  const getColorFromNumber = (colorNumber: number) => {
    if (colorNumber === 0) return "#FFFFFF"
    return `#${colorNumber.toString(16).padStart(6, "0")}`
  }

  return (
    <div className="grid grid-cols-10 gap-1 max-w-[600px] mx-auto">
      {squares.map((color, index) => (
        <div
          key={index}
          className={`aspect-square border ${
            selectedSquare === index
              ? "border-4 border-blue-500"
              : hoveredSquare === index
                ? "border-2 border-gray-400"
                : "border border-gray-200"
          } cursor-pointer transition-all duration-200 ease-in-out`}
          style={{ backgroundColor: getColorFromNumber(color) }}
          onClick={() => onSquareClick(index)}
          onMouseEnter={() => setHoveredSquare(index)}
          onMouseLeave={() => setHoveredSquare(null)}
        >
          <div className="w-full h-full flex items-center justify-center text-xs text-gray-500">{index}</div>
        </div>
      ))}
    </div>
  )
}
