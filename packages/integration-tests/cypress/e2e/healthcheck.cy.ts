import z from "zod"

describe("the healthcheck", () => {
  it("can run the :healthcheck", () => {
    cy.visit("http://localhost:5173")
    cy.startNeovim()

    // wait until text on the start screen is visible
    cy.contains("If you see this text, Neovim is ready!")

    cy.typeIntoTerminal(":checkhealth my-nvim-micro-plugins{enter}")

    // the version of the plugin should be shown
    cy.readFile("../../.release-please-manifest.json").then(
      (manifest: unknown) => {
        const version = z.object({ ".": z.string() }).parse(manifest)
        cy.contains(`Running version ${version["."]}`)
      },
    )

    cy.contains("found 'fd' version")
    cy.contains("found 'rg' version")
    cy.contains("found realpath")

    cy.contains("ERROR").should("not.exist")
  })

  it("can run the :healthcheck for telescope", () => {
    cy.visit("http://localhost:5173")
    cy.startNeovim()

    // wait until text on the start screen is visible
    cy.contains("If you see this text, Neovim is ready!")

    cy.typeIntoTerminal(":checkhealth telescope{enter}")

    cy.contains("ERROR").should("not.exist")
  })
})
