import React from "react"
import MapContext from "../context/MapContext"
import ReactSwipe from "react-swipe"

import { FaAngleLeft, FaAngleRight } from "react-icons/fa"

import find from "lodash/find"
import partition from "lodash/partition"
import zip from "lodash/zip"

import YearlyTrendChart from "../charts/yearly-trend"
import GenderPieChart from "../charts/gender-pie"


class BaseCards extends React.Component {

  onChange = (index) => {
    const { mapState } = this.props

    switch (index) {
      case 0:
        mapState.setSelectedLayer("municipales-not-found-count")
        break
      case 1:
        mapState.setSelectedLayer("municipales-dead-ct")
        break
      case 2:
        mapState.setSelectedLayer("municipales-status-ratio")
        break
      case 3:
        mapState.setSelectedLayer("municipales-gender-diff")
        break
    }
  }

  cardLegend = () => {
    const { mapState } = this.props
    const layer = find(mapState.style.layers, {"id": mapState.selectedLayer})
    if (!layer) return null

    // This is... inelegant
    const legendItems = zip(...partition(layer.paint["fill-color"].slice(3), (o) => parseFloat(o) ))
                          .map( (d) => ({color: d[1], value: d[0]}) )

    return (<>
      {legendItems.map( (item, i) => (
        <div key={`item-${i}`}>
          <span className="legend-box" style={{backgroundColor:item.color}} />
          {item.value}
        </div>
      ))}
    </>)
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
            <h2>Unsolved disappearances (@TODO be more descriptive)</h2>
            <div className="row">
              <div>{this.cardLegend()}</div>
              <div>
                <p>@TODO top level totals</p>
                <GenderPieChart />
                <p>^^ Gender chart should go on gender card</p>
              </div>
            </div>
            <p>@TODO put a timeseries here</p>
            <p>Swipe to see # of dead <FaAngleRight /> <br/>(@TODO replace with persistent control)</p>
          </div>
        </div>
        <div className="item">
          <div className="item-inner">
            <h2>Dead</h2>
            <div>{this.cardLegend()}</div>
            <p><FaAngleLeft /> Unsolved | Status ratio <FaAngleRight /></p>
          </div>
        </div>
        <div className="item">
          <div className="item-inner">
            <h2>Missing-or-dead to found ratio</h2>
            <div>{this.cardLegend()}</div>
            <p><FaAngleLeft /> Dead | Gender ratio <FaAngleRight /></p>
          </div>
        </div>
        <div className="item">
          <div className="item-inner">
            <h2>M-to-F ratio</h2>
            <div>{this.cardLegend()}</div>
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
