import React from "react"
import YearlyTrendChart from "../charts/yearly-trend"
import GenderPieChart from "../charts/gender-pie"

const Cards = () => {
  return (
    <div
      className="carousel"
    >
      <div className="item">
        <div className="item-inner">
          <GenderPieChart />
        </div>
      </div>
    </div>
  )
}

export default Cards
