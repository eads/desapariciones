import React from "react"
import { PieChart, Pie, Cell } from "recharts"
import MapContext from "../context/MapContext"
const COLORS = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042'];

class GenderPieChart extends React.Component {

  render() {
    return (
      <MapContext.Consumer>
        {mapState => { return (!mapState.data.length) ? null : (
          <PieChart height={100} width={100}>
            <Pie dataKey="value" data={mapState.genderSummary} innerRadius={30} outerRadius={50} fill="#8884d8" isAnimationActive={false}>
              {
                mapState.genderSummary.map((entry, index) => <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />)
              }
            </Pie>
          </PieChart>
        )}}
      </MapContext.Consumer>
    )
  }
}

export default GenderPieChart

