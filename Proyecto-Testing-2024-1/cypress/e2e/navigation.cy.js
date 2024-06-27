describe('Navigation', () => {
    beforeEach(() => {
      cy.visit('/');
      cy.request('POST', '/register', {
        user: {
          email: 'admin533@example.com',
          password: 'password',
          role: 'admin'
        }
      });
    });
  
    it('Register and see all normal user functions', () => {
      cy.visit('/products/index');
      cy.contains('Producto 1').should('exist');
      cy.contains('Producto 2').should('exist');
  
      cy.get('.navbar.is-fixed-top.is-info').click();
      cy.get('.navbar-end').click();
      cy.get('#navbarPrincipal').click();
      cy.get('.navbar-menu').click();
      cy.get('.navbar-item.has-dropdown.is-hoverable').click();
  
      cy.contains('Admin2').should('exist');
    });
  });