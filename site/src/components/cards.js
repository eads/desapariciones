import React from "react"
import MapContext from "../context/MapContext"
import ReactSwipe from "react-swipe"

import YearlyTrendChart from "../charts/yearly-trend"
import GenderPieChart from "../charts/gender-pie"


class BaseCards extends React.Component {

  onChange = (index) => {
    const { mapState } = this.props

    switch (index) {
      case 0:
        mapState.setSelectedLayer('municipales-not-found-count')
        break
      case 1:
        mapState.setSelectedLayer('municipales-gender-diff')
        break
    }
  }

  render() {
    let reactSwipeEl
    return (
      <ReactSwipe
        className="carousel"
        swipeOptions={{
          continuous: false,
          callback: this.onChange,
        }}
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
            <button onClick={() => reactSwipeEl.prev()}>Go back</button>
          </div>
        </div>
      </ReactSwipe>
    )
  }
}

class Cards extends React.Component {
  render() {
    return (
      <MapContext.Consumer>
        {mapState => (
          <BaseCards mapState={mapState} />
        )}
      </MapContext.Consumer>
    )
  }
}


export default Cards
