import { defineConfig } from 'checkly'
import { Frequency } from 'checkly/constructs'
import { myPrivateLocation } from './__checks__/private-locations.check'

export default defineConfig({
  projectName: 'pwcs-browser-artifact-repository',
  logicalId: 'pwcs-browser-artifact-repository',
  cli: {
    privateRunLocation: 'artifact-repo-example',
  },
  checks: {
    frequency: Frequency.EVERY_10M,
    locations: ['us-east-1'],
    tags: ['website'],
    runtimeId: '2025.04',
    playwrightConfigPath: './playwright.config.ts',
    playwrightChecks: [
      {
        name: 'Playwright Check - artifact repository',
        logicalId: 'pwcs-artifact-repository',
        frequency: Frequency.EVERY_24H,
        locations: [],
        privateLocations: [myPrivateLocation],
        environmentVariables: [
          {key: 'PLAYWRIGHT_DOWNLOAD_HOST', value: 'http://artifact-repo'}
        ]
      },
    ],
  },
})
