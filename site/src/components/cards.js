import React from "react"
import ReactSwipe from "react-swipe"
import YearlyTrendChart from "../charts/yearly-trend"

const Cards = () => {
  let reactSwipeEl
  return (
    <ReactSwipe
      className="carousel"
      swipeOptions={{ continuous: false }}
      ref={el => (reactSwipeEl = el)}
    >
      <div className="item">
        <div className="item-inner">
          <h1>Disappearances</h1>
          <h2>Subhed</h2>
          <p>Graf about what's next</p>
          <YearlyTrendChart />
          <button onClick={() => reactSwipeEl.next()}>Go fwd</button>
        </div>
      </div>
      <div className="item">
        <div className="item-inner">
          <p>go back</p>
          <button onClick={() => reactSwipeEl.prev()}>Go back</button>
        </div>
      </div>
    </ReactSwipe>
  )
}

export default Cards

/*

          <ReactSwipe
            className="carousel"
            swipeOptions={{ continuous: false }}
            ref={el => (reactSwipeEl = el)}
          >
            <div className="item">
              <div className="item-inner">
                <h1>Disappearances</h1>
                <h2>Subhed</h2>
                <p>Graf about what's next</p>
                <button onClick={() => reactSwipeEl.next()}>Explore the map</button>
              </div>
            </div>
            <div className="item">
              <div className="item-inner">
                <LineChart
                  width={300}
                  height={200}
                  data={processed_areas_geoestadisticas_estatales}
                  margin={{
                    top: 10, right: 10, left: 30, bottom: 10,
                  }}
                >
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="name" />
                  <YAxis />
                  {processed_areas_geoestadisticas_estatales.map(
                    (d, i) => {
                      return(<Line
                        type="monotone"
                        dataKey={(row) => {
                          return (row.cve_ent == d.cve_ent) ? Math.random() : 0 
                        }}
                        stroke={i % 2 ? colors[0] : colors[1]}
                        key={"line"+i}
                      />)
                    }
                  )}
                </LineChart>
                <button onClick={() => reactSwipeEl.prev()}>Read the preview</button>
              </div>
            </div>
            </ReactSwipe>
            */

/* import { LineChart, Line, CartesianGrid, XAxis, YAxis } from 'recharts'; */
           /*     let reactSwipeEl
    const { processed_areas_geoestadisticas_estatales } = this.props.data.desapariciones
const data = [
  {
    name: 'Page A', uv: 4000, pv: 2400, amt: 2400,
  },
  {
    name: 'Page B', uv: 3000, pv: 1398, amt: 2210,
  },
  {
    name: 'Page C', uv: 2000, pv: 9800, amt: 2290,
  },
  {
    name: 'Page D', uv: 2780, pv: 3908, amt: 2000,
  },
  {
    name: 'Page E', uv: 1890, pv: 4800, amt: 2181,
  },
  {
    name: 'Page F', uv: 2390, pv: 3800, amt: 2500,
  },
  {
    name: 'Page G', uv: 3490, pv: 4300, amt: 2100,
  },
];

    const colors = ['#cc0000', '#00cc00',]

*/
