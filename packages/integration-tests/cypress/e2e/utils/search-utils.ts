export const isSearchVisible = (): Cypress.Chainable<undefined> =>
  cy.contains("my-nvim-micro-plugins.nvim")
