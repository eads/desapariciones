import React from "react"
import MapContext from "../context/MapContext"
import ReactSwipe from "react-swipe"

import GenderPieChart from "../viz/gender-pie"
import MapLegend from "../viz/map-legend"
import TotalIndicator from "../viz/total-indicator"
import YearlyTrendChart from "../viz/yearly-trend"

import { FiChevronsRight, FiNavigation } from "react-icons/fi"

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
      case 3:
        mapState.setSelectedLayer("municipales-explore")
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
          continuous: false,
          callback: this.onChange,
        }}
      >
        <div className="item">
          <div className="item-inner">
            <MapLegend layer="municipales-not-found-count" />
            <h2>Inviting-but-serious headline to draw people in</h2>
            <p>Pro il terra populos traducite, iste super europeo pro in. Sine campo uno il, pardona technologia interlinguistica sed ma, o uno celos spatios litteratura. Per su usate sanctificate, multo cinque libere del es, de nomine populos publication sed. Sine super subjecto uso il. Web parolas personas scientia e.</p>
            <h3>By year</h3>
            <YearlyTrendChart data={this.props.desapariciones} />
            <div className="row">
              <p>Swipe for an important finding</p>
              <FiChevronsRight size="2.3vh" />
            </div>
          </div>
        </div>
        <div className="item">
          <div className="item-inner">
          <div className="item-inner">
            <MapLegend layer="municipales-not-found-count" />
            <h2>A simple but important finding</h2>
            <p>Pro il terra populos traducite, iste super europeo pro in. Sine campo uno il, pardona technologia interlinguistica sed ma, o uno celos spatios litteratura. Per su usate sanctificate, multo cinque libere del es, de nomine populos publication sed. Sine super subjecto uso il. Web parolas personas scientia e.</p>
            <div className="row">
              <p>Swipe for another important finding</p>
              <FiChevronsRight size="2.3vh" />
            </div>
          </div>
          </div>
        </div>
        <div className="item">
          <div className="item-inner">
            <MapLegend layer="gender-diff" />
            <h2>M-to-F ratio</h2>
            <GenderPieChart />
          </div>
        </div>
        <div className="item">
          <div className="item-inner">
            <MapLegend layer="municipales-not-found-count" />
            <h2>Explore</h2>

            <p>(LITTLE PICTURE) Tap states to filter by them</p>
            <p>(LITTLE PICTURE) Pinch and zoom to move around the map</p>

            <p>Pick additional layers to show</p>

            <TotalIndicator />
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
