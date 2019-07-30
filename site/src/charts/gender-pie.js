import React from "react"
import { PieChart, Pie, Cell } from "recharts"
import MapContext from "../context/MapContext"
import { intcomma } from "journalize"
const COLORS = ['#999999', '#000000'];

class GenderPieChart extends React.Component {

  processData = (data) => {
    if (!data.length) return null

    const genderCount = {
      m: 0,
      f: 0,
    }

    data.forEach( (d) => {
      if (d.properties.gender_fem_ct) genderCount.f += d.properties.gender_fem_ct
      if (d.properties.gender_masc_ct) genderCount.m += d.properties.gender_masc_ct
    })

    return [
      { name: "m", value: genderCount.m },
      { name: "f", value: genderCount.f },
    ]
  }

  render() {
    return (
      <MapContext.Consumer>
        {mapState => {
            const data = this.processData(mapState.data)
            return (!data) ? null : (<>
              <h2>Sexo</h2>
              <div className="chart donut-chart">
                <PieChart height={50} width={50}>
                  <Pie dataKey="value" data={data} innerRadius={15} outerRadius={25} fill="#8884d8" isAnimationActive={false}>
                    {
                      data.map((entry, index) => <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />)
                    }
                  </Pie>
                </PieChart>
                <table>
                  <tbody>
                    <tr>
                      <th>
                        Masc
                      </th>
                      <td>
                        {intcomma(data[0].value)}
                      </td>
                    </tr>
                    <tr>
                      <th>
                        Fem
                      </th>
                      <td>
                        {intcomma(data[1].value)}
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </>)
          }
        }
      </MapContext.Consumer>
    )
  }
}

export default GenderPieChart
