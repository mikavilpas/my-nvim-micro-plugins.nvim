describe("the healthcheck", () => {
  it("can run the :healthcheck", () => {
    cy.visit("/")
    cy.startNeovim().then((nvim) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")

      nvim.runExCommand({ command: "checkhealth my-nvim-micro-plugins" })

      // the version of the plugin should be shown
      cy.readFile("../../lua/my-nvim-micro-plugins.lua").then(
        (luaFile: string) => {
          const match = luaFile.match(/M\.version\s*=\s*"([^"]+)"/)
          if (!match) {
            throw new Error("Could not find version in lua file")
          }
          const version = match[1]
          cy.contains(`Running version ${version}`)
        },
      )

      cy.contains("found 'fd' version")
      cy.contains("found 'rg' version")
      cy.contains("found realpath")

      cy.contains("ERROR").should("not.exist")
    })
  })
})
