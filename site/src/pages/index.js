import React from "react"
import { graphql } from 'gatsby'

import Layout from "../components/layout"
import SEO from "../components/seo"
import Cards from "../components/cards"
import Map from "../components/map"

// This should go in the map component
import ViewportIndicator from "../viz/viewport-indicator"

const IndexPage = ({data}) => {
  return (
    <Layout>
      <SEO title="Map" />
      <div className="explorer-pane">
        <Cards {...data} />
        <ViewportIndicator />
      </div>
      <div className="map-pane">
        <Map />
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
