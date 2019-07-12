import React from "react"
import { BarChart, Bar, XAxis, YAxis, ResponsiveContainer } from "recharts"
import MapContext from "../context/MapContext"

class YearlyTrendChart extends React.Component {

  yTickFormatter = (value) => {
    if (Math.floor(Math.log10(value)) > 2) {
      return `${Math.floor(value/1e3)}k`
    } else {
      return value
    }
  }

  xTickFormatter = (value) => {
    switch (value) {
      case "Baja California Sur":
      case "Baja California":
        return value.replace("California", "Cali.")
      case "Veracruz de Ignacio de la Llave":
        return "Veracruz"
      case "Ciudad de México":
        return "CDMX"
      case "Coahuila de Zaragoza":
        return "Coahulia"
      case "Michoacán de Ocampo":
        return "Michoacán"
      default:
        return value
    }
  }

  render() {
    return (
      <MapContext.Consumer>
        {mapState => (
          <ResponsiveContainer
            aspect={.7}
          >
            <BarChart
              data={mapState.stateSummary}
              layout="vertical"
              margin={{
                top: 10, right: 10, left: 0, bottom: 40,
              }}
            >
              <YAxis
                dataKey="state"
                interval={0}
                type="category"
                width={110}
                tickFormatter={this.xTickFormatter}
              />
              <XAxis
                tickFormatter={this.yTickFormatter}
                type="number"
                interval={3}
              />
              <Bar
                dataKey="disappearances"
                fill="#8884d8"
              />
            </BarChart>
          </ResponsiveContainer>
        )}
      </MapContext.Consumer>
    )
  }
}

export default YearlyTrendChart
