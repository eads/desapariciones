import React from "react"
import { graphql } from "gatsby"

import Layout from "../components/layout"
import SEO from "../components/seo"

import ReactSwipe from "react-swipe"

import ReactMapGL from "react-map-gl"
import "mapbox-gl/dist/mapbox-gl.css"

import { LineChart, Line, CartesianGrid, XAxis, YAxis } from 'recharts';

const MAPBOX_TOKEN = "pk.eyJ1IjoiZGF2aWRlYWRzIiwiYSI6ImNpZ3d0azN2YzBzY213N201eTZ3b2E0cDgifQ.ZCHD8ZAk32iAp9Ue3tPVVg"

class IndexPage extends React.Component {
  state = {
    viewport: {
      width: '100%',
      height: '100%',
      longitude: -102.9,
      latitude: 23.42,
      zoom: 3.1,
    }
  }

  render() {

    let reactSwipeEl
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

    return (
      <Layout>
        <SEO title="Map" />
        <div className="explorer-pane">
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

        </div>

        <div className="map-pane">
          <ReactMapGL
            {...this.state.viewport}
            onViewportChange={(viewport) => this.setState({viewport})}
            mapboxApiAccessToken={MAPBOX_TOKEN}
            mapStyle="mapbox://styles/davideads/cjxhxnw2a3vz81cr178aj3syc"
          />
        </div>
      </Layout>
    );
  }
}

export default IndexPage

export const query = graphql`
  query {
    desapariciones {
      processed_areas_geoestadisticas_estatales {
        nom_ent
        cve_ent
        cenapi_by_year {
          year
          count
          cumulative_count
        }
      }
    }
  }
`

/*
 *
 *                 <VictoryChart
                  domainPadding={10}
                  height={200}
                  width={400}
                  theme={VictoryTheme.material}
                  >
                  <VictoryAxis dependentAxis
                    tickFormat={(tick) => (tick / 1000) + 'k'}
                  />
                  <VictoryAxis
                    tickFormat={(tick) => (tick)}
                  />
                  <VictoryLabel style={{size:5}}/>
                  <VictoryStack>
                    {processed_areas_geoestadisticas_estatales.map(
                      (d, i) => (
                        <VictoryArea
                          interpolation="monotoneX"
                          data={d.cenapi_by_year}
                          x="year"
                          y="cumulative_count"
                          key={"Line-" + i}
                        />
                      )
                    )}
                  </VictoryStack>
                  </VictoryChart>
                  */
