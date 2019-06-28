import React from "react"
import { graphql, Link } from "gatsby"

import Layout from "../components/layout"
import Image from "../components/image"
import SEO from "../components/seo"

import DeckGL from '@deck.gl/react'
import {ScatterplotLayer} from '@deck.gl/layers'
import {StaticMap} from 'react-map-gl'

const MAPBOX_TOKEN = 'pk.eyJ1IjoiYWRvbmRldmFuIiwiYSI6ImNqbm0yc2x3aDA0c2QzcXVteWhjaW5vZTMifQ.9iTMcfENx9TOCQ94oXEevQ'

const INITIAL_VIEW_STATE = {
  longitude: -99.12,
  latitude: 19.42,
  zoom: 4.25,
  maxZoom: 16,
  pitch: 0,
  bearing: 0
};

const IndexPage = (context) => {
  const data = context.data.desapariciones.views_areas_geoestadisticas_municipales_centroids


  const layer = new ScatterplotLayer({
    id: 'scatterplot-layer',
    data,
    //pickable: true,
    opacity: 1,
    stroked: false,
    filled: true,
    radiusScale: 10,
    radiusMinPixels: 1.25,
    radiusMaxPixels: 80,
    lineWidthMinPixels: 1,
    getPosition: d => [d.lng, d.lat],
    getRadius: d => d.cenapi_by_year_aggregate.aggregate.sum.count,
    getFillColor: d => [255, 140, 0],
    getLineColor: d => [0, 0, 0],
  })

  const mapStyle = 'mapbox://styles/mapbox/light-v9';

  return( <Layout>
    <SEO title="Home" />
    <DeckGL layers={[layer]} initialViewState={INITIAL_VIEW_STATE} controller={true}>
        <StaticMap
          reuseMaps
          mapStyle={mapStyle}
          preventStyleDiffing={true}
          mapboxApiAccessToken={MAPBOX_TOKEN}
        />
    </DeckGL>
  </Layout>)
}

export default IndexPage

export const query = graphql`
  query {
    desapariciones {
      views_areas_geoestadisticas_municipales_centroids(where: {cenapi_by_year: {cve_geoid: {_is_null: false}}}) {
        nom_mun
        nom_ent
        lat
        lng
        cenapi_by_year_aggregate {
          aggregate {
            sum {
              count
            }
          }
        }
        cenapi_by_year {
          year
          count
        }
      }
    }
  }
`
