import React from "react"
import { BarChart, Bar, XAxis, YAxis, ResponsiveContainer } from "recharts"
import MapContext from "../context/MapContext"
import groupBy from "lodash/groupBy"
import sumBy from "lodash/sumBy"
import filter from "lodash/filter"

class YearlyTrendChart extends React.Component {

  renderChart = (mapState) => {
    const { views_cenapi_by_year } = this.props.data
    const ids = mapState.data.map( (d) => d.properties.id )
    const filtered = filter(views_cenapi_by_year, (d) => (ids.includes(d.cve_geoid)))
    const groups = groupBy(filtered, "year")
    const data = Object.entries(groups).map(([key, value]) => ({
      year: key,
      disappearance_ct: sumBy(value, 'disappearance_ct'),
    }))

    return (
      <ResponsiveContainer
        width="100%"
        height={80}
      >
        <BarChart
          data={data}
          margin={{
            top: 10, right: 10, left: -10, bottom: 0,
          }}
        >
          <YAxis
            dataKey="disappearance_ct"
          />
          <XAxis
            dataKey="year"
          />
          <Bar
            dataKey="disappearance_ct"
            fill="#999999"
            isAnimationActive={false}
          />
        </BarChart>
      </ResponsiveContainer>
    )
  }

  render() {
    return (
      <div className="yearly-trend-chart">
        <MapContext.Consumer>
          {mapState => { return (mapState.data.length) ? this.renderChart(mapState) : null }}
        </MapContext.Consumer>
      </div>
    )
  }
}

export default YearlyTrendChart

/*
 *       <ResponsiveContainer
        width="100%"
        height={400}
      >
        <BarChart
          data={mapState.stateSummary}
          layout="vertical"
          margin={{
            top: 10, right: 10, left: -20, bottom: 0,
          }}
        >
          <YAxis
            dataKey="state"
            interval={0}
            type="category"
            width={130}
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
      </ResponsiveContainer>*/
