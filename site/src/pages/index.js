import React from "react"
import { graphql } from 'gatsby'

import Layout from "../components/layout"
import SEO from "../components/seo"
import Cards from "../components/cards"
import Map from "../components/map"
import MapOverlay from "../components/mapoverlay"

import MapLegend from "../viz/map-legend"
import SelectedIndicator from "../viz/selected-indicator"


const IndexPage = ({data}) => {
  return (
    <Layout>
      <SEO title="Map" />
      <div className="map-pane">
        <Map />
      </div>
      <div className="info-pane">
        <MapLegend />
      </div>
      <div className="explorer-pane">
        <Cards {...data} />
      </div>
    </Layout>
  )
}

export default IndexPage


export const query = graphql`
  query IndexPageQuery {
    desapariciones {
      views_cenapi_by_year {
        cve_geoid
        year
        gender_fem_ct
        gender_masc_ct
        status_dead_ct
        status_not_found_ct
        status_alive_ct
        disappearance_ct
      }
    }
  }
`

/*

*/
