import React from "react"
import MapContext from "../context/MapContext"
import ReactSwipe from "react-swipe"

import { FaAngleLeft, FaAngleRight } from "react-icons/fa"


import GenderPieChart from "../charts/gender-pie"
import MapLegend from "../charts/map-legend"


class BaseCards extends React.Component {

  onChange = (index) => {
    const { mapState } = this.props

    switch (index) {
      case 0:
        mapState.setSelectedLayer("municipales-not-found-count")
        break
      case 1:
        mapState.setSelectedLayer("municipales-status-ratio")
        break
      case 2:
        mapState.setSelectedLayer("municipales-gender-diff")
        break
      default:
        mapState.setSelectedLayer("municipales-not-found-count")
    }
  }



  render() {
    return (
      <ReactSwipe
        className="carousel"
        swipeOptions={{
          continuous: true,
          callback: this.onChange,
        }}
      >
        <div className="item">
          <div className="item-inner">
            <h2>Unsolved disappearances (@TODO be more descriptive)</h2>
            <div className="row">
              <MapLegend
                layer="municipales-not-found-count"
              />
              <div>
                <p>@TODO top level totals</p>
              </div>
            </div>
            <p>@TODO put a timeseries here</p>
            <p>Swipe to see # of dead <FaAngleRight /> <br/>(@TODO replace with persistent control)</p>
          </div>
        </div>
        <div className="item">
          <div className="item-inner">
            <h2>Missing-or-dead to found ratio</h2>
            <MapLegend
              layer="municipales-status-ratio"
            />
            <p><FaAngleLeft /> Dead | Gender ratio <FaAngleRight /></p>
          </div>
        </div>
        <div className="item">
          <div className="item-inner">
            <MapLegend
              layer="gender-diff"
            />
            <h2>M-to-F ratio</h2>
            <GenderPieChart />
            <p><FaAngleLeft /> Status ratio</p>
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
