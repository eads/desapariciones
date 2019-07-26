import React from "react"
import YearlyTrendChart from "../charts/yearly-trend"
import GenderPieChart from "../charts/gender-pie"
import ReactSwipe from "react-swipe"


const Cards = () => {
  let reactSwipeEl
  return (
    <ReactSwipe
      className="carousel"
      swipeOptions={{ continuous: false }}
      ref={el => (reactSwipeEl = el)}
    >
      <div className="item">
        <div className="item-inner">
          <GenderPieChart />
          <button onClick={() => reactSwipeEl.next()}>Go fwd</button>
        </div>
      </div>
      <div className="item">
        <div className="item-inner">
          <p>Other slide</p>
        </div>
      </div>
    </ReactSwipe>
  )
}

export default Cards
