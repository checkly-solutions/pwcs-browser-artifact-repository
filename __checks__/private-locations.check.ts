import { PrivateLocation } from 'checkly/constructs'

export const myPrivateLocation = new PrivateLocation('private-location-1', {
  name: 'Location - Artifact Repo Example',
  slugName: 'artifact-repo-example'
})