describe("multicursor-nvim integration", () => {
  function redraw() {
    // there are some bugs with the terminal right now and this seems to work
    // around them
    cy.typeIntoTerminal("{control+l}")
  }

  it("can add to the start of lines", () => {
    cy.visit("http://localhost:5173")
    cy.startNeovim({ filename: "multicursor-file.lua" }).then(() => {
      // wait until text on the start screen is visible
      cy.contains("is_visual_line")

      // make sure the cursor is at the end so we can test that
      cy.typeIntoTerminal("$Vjj")
      redraw()
      cy.typeIntoTerminal("Ii--{esc}")

      // the text should now be commented out for all lines
      cy.contains("--local mode = vim.fn.mode()")
    })
  })

  it("can add to the end of lines", () => {
    cy.visit("http://localhost:5173")
    cy.startNeovim({ filename: "multicursor-file.lua" }).then(() => {
      // wait until text on the start screen is visible
      cy.contains("is_visual_line")

      // make sure the cursor is at the start so we can test that
      cy.typeIntoTerminal("0Vjj")
      redraw()
      cy.typeIntoTerminal("Aa-- comment{esc}")

      // the text should now be changed
      cy.contains("local mode = vim.fn.mode()-- comment")
    })
  })

  it("can add to the start of a visual block selection", () => {
    cy.visit("http://localhost:5173")
    cy.startNeovim({ filename: "multicursor-file.lua" }).then(() => {
      // wait until text on the start screen is visible
      cy.contains("is_visual_line")

      // move to the second word
      cy.typeIntoTerminal("w")

      cy.typeIntoTerminal("{control+v}jjI")
      cy.typeIntoTerminal("itest_{esc}")

      cy.contains("local test_is_visual_line")
    })
  })
})
