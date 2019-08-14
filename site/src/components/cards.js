import React from "react"
import MapContext from "../context/MapContext"
import ReactSwipe from "react-swipe"

import GenderPieChart from "../viz/gender-pie"
import MapLegend from "../viz/map-legend"
import TotalIndicator from "../viz/total-indicator"
import YearlyTrendChart from "../viz/yearly-trend"

import { FiChevronsRight, FiNavigation } from "react-icons/fi"

import swipeGIF from '../gifs/swipe.gif'


class BaseCards extends React.Component {

  onChange = (index) => {
    const { mapState } = this.props

    switch (index) {
      case 0:
        mapState.setSelectedLayer("municipales-not-found-count")
        break
      case 1:
        mapState.setSelectedLayer("municipales-not-found-count")
        break
      case 2:
        mapState.setSelectedLayer("municipales-gender-diff")
        break
      case 3:
        mapState.setSelectedLayer("municipales-status-ratio")
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
            <h2>Explore Mexico's Disappearances</h2>
            <p>Pro il terra populos traducite, iste super europeo pro in. Sine campo uno il, pardona technologia interlinguistica sed ma, o uno celos spatios litteratura.</p>

            <div className="row instruction-row">
              <img src={swipeGIF} alt="Swipe gif" />
              <p>Swipe to show layers</p>
            </div>
            <div className="row instruction-row">
              <img src={swipeGIF} alt="Swipe gif" />
              <p>Tap to select state</p>
            </div>
          </div>
        </div>
        <div className="item">
          <div className="item-inner">
          <div className="item-inner">
            <h2>Overview / timeline</h2>
            <YearlyTrendChart data={this.props.desapariciones} />
            <div className="row">
              <p>Swipe for gender</p>
              <FiChevronsRight size="2.3vh" />
            </div>
          </div>
          </div>
        </div>
        <div className="item">
          <div className="item-inner">
            <h2>Gender</h2>
            <GenderPieChart />
          </div>
        </div>
        <div className="item">
          <div className="item-inner">
            <h2>Age</h2>
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
