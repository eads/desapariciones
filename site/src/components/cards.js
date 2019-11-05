import React from "react"
import MapContext from "../context/MapContext"
import ReactSwipe from "react-swipe"


class BaseCards extends React.Component {
  onChange = (index) => {
    const { mapState } = this.props
    mapState.setCard(index)
  }

  render() {
    return (
      <ReactSwipe
        className="carousel"
        swipeOptions={{
          continuous: true,
          transitionEnd: this.onChange,
        }}
      >
        <div className="item">
          <div className="item-inner">
            slide 1
          </div>
        </div>
        <div className="item">
          <div className="item-inner">
            slide 2
          </div>
        </div>
        <div className="item">
          <div className="item-inner">
            slide 3
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
