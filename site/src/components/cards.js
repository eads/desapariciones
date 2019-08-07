import React from "react"
import MapContext from "../context/MapContext"
import ReactSwipe from "react-swipe"

import GenderPieChart from "../viz/gender-pie"
import MapLegend from "../viz/map-legend"
import TotalIndicator from "../viz/total-indicator"
import YearlyTrendChart from "../viz/yearly-trend"


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
              <TotalIndicator />
              <div>@TODO put some text here</div>
            </div>
            <YearlyTrendChart data={this.props.desapariciones} />
            <MapLegend layer="municipales-not-found-count" />
          </div>
        </div>
        <div className="item">
          <div className="item-inner">
            <h2>Missing-or-dead to found ratio</h2>
            <MapLegend
              layer="municipales-status-ratio"
            />
          </div>
        </div>
        <div className="item">
          <div className="item-inner">
            <MapLegend
              layer="gender-diff"
            />
            <h2>M-to-F ratio</h2>
            <GenderPieChart />
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
          <BaseCards mapState={mapState} {...this.props} />
        )}
      </MapContext.Consumer>
    )
  }
}


export default Cards
