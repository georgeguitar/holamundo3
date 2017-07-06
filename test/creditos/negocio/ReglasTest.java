/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package creditos.negocio;

import almacenes.negocio.Reglas;
import almacenes.negocio.mapeo.Credito;
import almacenes.negocio.mapeo.Persona;
import almacenes.negocio.mapeo.PersonaTieneCredito;
import almacenes.negocio.mapeo.Usuario;
import java.util.ArrayList;
import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import static org.junit.Assert.*;

/**
 *
 * @author georgeguitar
 */
public class ReglasTest {
    
    public ReglasTest() {
    }
    
    @BeforeClass
    public static void setUpClass() {
    }
    
    @AfterClass
    public static void tearDownClass() {
    }
    
    @Before
    public void setUp() {
    }
    
    @After
    public void tearDown() {
    }

    /**
     * Test of insertarPersonaTieneCredito method, of class Reglas.
     */
    @Test
    public void testInsertarPersonaTieneCredito() throws Exception {
        System.out.println("insertarPersonaTieneCredito");
        PersonaTieneCredito personaTieneCredito = null;
        Reglas instance = null;
        Integer expResult = null;
        Integer result = instance.insertarPersonaTieneCredito(personaTieneCredito);
        assertEquals(expResult, result);
        // TODO review the generated test code and remove the default call to fail.
        fail("The test case is a prototype.");
    }

    /**
     * Test of insertarCreditoDB method, of class Reglas.
     */
    @Test
    public void testInsertarCreditoDB() throws Exception {
        System.out.println("insertarCreditoDB");
        Credito credito = null;
        Reglas instance = null;
        Long expResult = null;
        Long result = instance.insertarCreditoDB(credito);
        assertEquals(expResult, result);
        // TODO review the generated test code and remove the default call to fail.
        fail("The test case is a prototype.");
    }

    /**
     * Test of insertarUsuarioDB method, of class Reglas.
     */
    @Test
    public void testInsertarUsuarioDB() throws Exception {
        System.out.println("insertarUsuarioDB");
        Usuario usuario = null;
        Reglas instance = null;
        Long expResult = null;
        Long result = instance.insertarUsuarioDB(usuario);
        assertEquals(expResult, result);
        // TODO review the generated test code and remove the default call to fail.
        fail("The test case is a prototype.");
    }

    /**
     * Test of insertarPersonaDB method, of class Reglas.
     */
    @Test
    public void testInsertarPersonaDB() throws Exception {
        System.out.println("insertarPersonaDB");
        Persona persona = null;
        Reglas instance = null;
        Long expResult = null;
        Long result = instance.insertarPersonaDB(persona);
        assertEquals(expResult, result);
        // TODO review the generated test code and remove the default call to fail.
        fail("The test case is a prototype.");
    }

    /**
     * Test of calcularPlanPagos method, of class Reglas.
     */
    @Test
    public void testCalcularPlanPagos() throws Exception {
        System.out.println("calcularPlanPagos");
        Long idCredito = null;
        String decimales = "";
        Reglas instance = null;
        instance.calcularPlanPagos(idCredito, decimales);
        // TODO review the generated test code and remove the default call to fail.
        fail("The test case is a prototype.");
    }

    /**
     * Test of insertarPlanPagosDB method, of class Reglas.
     */
    @Test
    public void testInsertarPlanPagosDB() throws Exception {
        System.out.println("insertarPlanPagosDB");
        Long idCredito = null;
        ArrayList<ArrayList<String>> planPagosFinal = null;
        Reglas instance = null;
        instance.insertarPlanPagosDB(idCredito, planPagosFinal);
        // TODO review the generated test code and remove the default call to fail.
        fail("The test case is a prototype.");
    }

    /**
     * Test of buscarPersona method, of class Reglas.
     */
    @Test
    public void testBuscarPersona() throws Exception {
        System.out.println("buscarPersona");
        Persona personaBuscada = null;
        Reglas instance = null;
        ArrayList<Persona> expResult = null;
//        ArrayList<Persona> result = instance.buscarPersona(personaBuscada);
//        assertEquals(expResult, result);
        // TODO review the generated test code and remove the default call to fail.
        fail("The test case is a prototype.");
    }
    
}
