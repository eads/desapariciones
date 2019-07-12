import React from "react"
import { MapProvider } from "./src/context/MapContext"

export const wrapRootElement = ({ element }) => (
  <MapProvider>{element}</MapProvider>
)
