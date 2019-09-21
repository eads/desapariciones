import React from "react"
import MapContext from "../context/MapContext"
import ReactSwipe from "react-swipe"

import GenderPieChart from "../viz/gender-pie"
import TotalIndicator from "../viz/total-indicator"
import YearlyTrendChart from "../viz/yearly-trend"

import { FormattedMessage} from "gatsby-plugin-intl"

import { FiChevronsRight, FiNavigation } from "react-icons/fi"

import swipeGIF from '../gifs/swipe.gif'

const CARDS = [
  {id: "intro", layer: "municipales-not-found-count-init"},
  {id: "not-found", layer: "municipales-not-fount-count"},
  {id: "gender-diff", layer: "municipales-gender-diff"},
  {id: "status-ratio", layer: "municipales-status-ratio"},
  {id: "outro", layer: "municipales-not-found-count-init"},
]

class Card extends React.Component {

  _intro = (id) => (<>
    <h2><FormattedMessage id="cards.intro.title" /></h2>
    <p><FormattedMessage id="cards.intro.lede" /></p>

    <div className="row instruction-row">
      <img src={swipeGIF} alt="Swipe gif" />
      <p><FormattedMessage id="cards.intro.swipeMessage" /></p>
    </div>
    <div className="row instruction-row">
      <img src={swipeGIF} alt="Swipe gif" />
      <p><FormattedMessage id="cards.intro.tapMessage" /></p>
    </div>
  </>)

  _default = () => (<>
    <h1>Hello world</h1>
    <p><FormattedMessage id="cards.intro.lede" /></p>
    <p><FormattedMessage id="cards.intro.lede" /></p>
    <p><FormattedMessage id="cards.intro.lede" /></p>
    <p><FormattedMessage id="cards.intro.lede" /></p>
    <p><FormattedMessage id="cards.intro.lede" /></p>
    <p><FormattedMessage id="cards.intro.lede" /></p>
    <p><FormattedMessage id="cards.intro.lede" /></p>
    <p><FormattedMessage id="cards.intro.lede" /></p>
    <p><FormattedMessage id="cards.intro.lede" /></p>
    <p><FormattedMessage id="cards.intro.lede" /></p>
  </>)

  render() {
    switch (this.props.id) {
      case "intro":
        return this._intro(this.props.id)
      default:
        return this._default()
    }
  }
}


class BaseCards extends React.Component {

  onChange = (index) => {
    const { mapState } = this.props
    mapState.setSelectedLayer(CARDS[index].layer)
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
        {CARDS.map((card) => (
          <div key={card.id} className="item">
            <Card {...card} />
          </div>
        ))}
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

/*

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

            <p>Pro il terra populos traducite, iste super europeo pro in. Sine campo uno il, pardona technologia interlinguistica sed ma, o uno celos spatios litteratura.</p>
            <p>Pro il terra populos traducite, iste super europeo pro in. Sine campo uno il, pardona technologia interlinguistica sed ma, o uno celos spatios litteratura.</p>
          </div>
        </div>

        <div className="item">
          <div className="item-inner">
          <div className="item-inner">
            <h2>Overview / timeline</h2>
            <YearlyTrendChart data={this.props.desapariciones} />
            <div className="row">
              <TotalIndicator />
              <p>Eos ipsum expetenda te, no dicunt voluptatum pri, ut mea diam feugiat atomorum. Liber definitionem ius no, usu an iisque integre. An iusto comprehensam ius.</p>
            </div>
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
            <p>Eos ipsum expetenda te, no dicunt voluptatum pri, ut mea diam feugiat atomorum. Liber definitionem ius no, usu an iisque integre. An iusto comprehensam ius! Vix etiam utroque ne, justo aliquam in usu.</p>
          </div>
          </div>

        <div className="item">
          <div className="item-inner">
            <h2>Age</h2>
            <p>Eos ipsum expetenda te, no dicunt voluptatum pri, ut mea diam feugiat atomorum. Liber definitionem ius no, usu an iisque integre. An iusto comprehensam ius! Vix etiam utroque ne, justo aliquam in usu.</p>
            <p>Eos ipsum expetenda te, no dicunt voluptatum pri, ut mea diam feugiat atomorum. Liber definitionem ius no, usu an iisque integre. An iusto comprehensam ius! Vix etiam utroque ne, justo aliquam in usu.</p>
          </div>
          </div>
*/
