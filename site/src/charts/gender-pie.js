import React from "react"
import { PieChart, Pie, Cell } from "recharts"
import MapContext from "../context/MapContext"
const COLORS = ['#999999', '#000000'];

class GenderPieChart extends React.Component {

  render() {
    return (
      <MapContext.Consumer>
        {mapState => { return (!mapState.data.length) ? null : (<>

          <PieChart height={60} width={60}>
            <Pie dataKey="value" data={mapState.genderSummary} innerRadius={15} outerRadius={30} fill="#8884d8" isAnimationActive={false}>
              {
                mapState.genderSummary.map((entry, index) => <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />)
              }
            </Pie>
          </PieChart>

          <p>M: {mapState.genderSummary[0].value}</p>
          <p>F: {mapState.genderSummary[1].value}</p>
        </>)}}
      </MapContext.Consumer>
    )
  }
}

export default GenderPieChart

