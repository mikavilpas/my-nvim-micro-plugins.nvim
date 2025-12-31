describe("the healthcheck", () => {
  it("can run the :healthcheck", () => {
    cy.visit("/")
    cy.startNeovim().then((nvim) => {
      // wait until text on the start screen is visible
      cy.contains("If you see this text, Neovim is ready!")

      nvim.runExCommand({ command: "checkhealth my-nvim-micro-plugins" })

      cy.contains("found 'fd' version")
      cy.contains("found 'rg' version")
      cy.contains("found realpath")

      cy.contains("ERROR").should("not.exist")
    })
  })
})
