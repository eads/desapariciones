import React from "react"
import MapContext from "../context/MapContext"
import sumBy from "lodash/sumBy"
import { intcomma } from "journalize"

class TotalIndicator extends React.Component {

  renderTotal = (mapState) => {
    const total = sumBy(mapState.data, 'properties.disappearance_ct')
    const missing = sumBy(mapState.data, 'properties.status_not_found_ct')
    const dead = sumBy(mapState.data, 'properties.status_dead_ct')
    const alive = sumBy(mapState.data, 'properties.status_alive_ct')

    return (<table>
      <tbody>
        <tr>
          <th>Total</th>
          <td>{intcomma(total)}</td>
        </tr>
        <tr>
          <th>Missing</th>
          <td>{intcomma(missing)}</td>
        </tr>
        <tr>
          <th>Alive</th>
          <td>{intcomma(alive)}</td>
        </tr>
        <tr>
          <th>Dead</th>
          <td>{intcomma(dead)}</td>
        </tr>
      </tbody>
    </table>)
  }

  render() {
    return (
      <div className="total-indicator">
        <MapContext.Consumer>
          {mapState => this.renderTotal(mapState)}
        </MapContext.Consumer>
      </div>
    )
  }
}

export default TotalIndicator
