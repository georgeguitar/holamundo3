

import java.sql.Connection;
import java.sql.Date;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Calendar;

import almacenes.conectorDB.DatabaseUtils;
import almacenes.negocio.Reglas;
import almacenes.negocio.mapeo.Credito;
import almacenes.negocio.mapeo.Persona;
import almacenes.negocio.mapeo.PersonaTieneCredito;
import almacenes.negocio.mapeo.Usuario;

public class InsertarCreditoTest {

	public static Connection connection;
	public static Statement stmt; 
	public static ResultSet rs;
	
	static DatabaseUtils databaseUtils;
	
    private static final String DEFAULT_DRIVER = "org.postgresql.Driver";
    private static final String DEFAULT_URL = "jdbc:postgresql://localhost:5432/creditosDB";
    private static final String DEFAULT_USERNAME = "postgres";
    private static final String DEFAULT_PASSWORD = "postgres";
	
	static final String CLIENTE = "CLIENTE";
	static final String GARANTE = "GARANTE";
	static final String BOLIVIANOS = "BOB";
	static final String DOLARES = "$US";
	static final String CUOTA_FIJA = "CUOTA_FIJA";
	static final String INTERES_FIJO = "INTERES_FIJO";
	static final String NINGUNO = "NINGUNO";
	
	static String Decimales = "%.2f";  // Dos decimales	
	
	public static void main(String[] args) {
/*
		String url = "jdbc:postgresql://localhost:5432/creditosDB";
		Properties props = new Properties();
		props.setProperty("user","postgres");
		props.setProperty("password","postgres");
//		props.setProperty("ssl","true");
		connection = DriverManager.getConnection(url, props);
*/
        try {
        	databaseUtils = new DatabaseUtils();
			connection = databaseUtils.createConnection(DEFAULT_DRIVER, DEFAULT_URL, DEFAULT_USERNAME, DEFAULT_PASSWORD);
			Reglas reglas = new Reglas(databaseUtils, connection);
/*

			//Trabajo connection Usuarios
			Usuario usuario = new Usuario();
			usuario.setCI(8484844);
			usuario.setNombres("Pedro");
			usuario.setApPaterno("Madrigas");
			usuario.setApMaterno("Corredon");
			usuario.setSexo('M');
			
			Calendar calendar = Calendar.getInstance();
			calendar.set(Calendar.YEAR, 1990);
			calendar.set(Calendar.DAY_OF_MONTH, 1);
			calendar.set(Calendar.MONTH, 4); // Assuming you wanted May 1st
			usuario.setFechaNacimiento(new Date(calendar.getTime().getTime()));
			usuario.setTelefono("233445");
			usuario.setTelCelular("67233445");
			usuario.setEmail("jfjdn@kfkff.com");
			usuario.setDireccion("Calle dmdmd");
			usuario.setCargo("Secretaria");
			usuario.setDatosAdicionales("Sigue en la U");
			Long idUsuario = reglas.insertarUsuarioDB(usuario);
			System.out.println("idusuario: " + idUsuario);
			
		
			//Trabajo connection personas
			//Como cliente
			Persona cliente = new Persona();
			cliente.setCI(8484844);
			cliente.setNombres("Pedro");
			cliente.setApPaterno("Madrigas");
			cliente.setApMaterno("Corredon");
			cliente.setSexo('M');
			calendar = Calendar.getInstance();
			calendar = Calendar.getInstance();
			calendar.set(Calendar.YEAR, 1990);
			calendar.set(Calendar.DAY_OF_MONTH, 1);
			calendar.set(Calendar.MONTH, 4); // Assuming you wanted May 1st
			cliente.setFechaNacimiento(new Date(calendar.getTime().getTime()));
			cliente.setTelefono("233445");
			cliente.setTelCelular("67233445");
			cliente.setEmail("jfjdn@kfkff.com");
			cliente.setOcupacion("Carpintero");
			cliente.setDatosAdicionales("Tiene dos perros");
			Long idCliente = reglas.insertarPersonaDB(cliente);
			System.out.println("idCliente: " + idCliente);	

			
			//Como garante
			Persona garante = new Persona();
			garante.setCI(8484844);
			garante.setNombres("Alicia");
			garante.setApPaterno("Keys");
			garante.setApMaterno("Umbrella");
			garante.setSexo('F');
			calendar = Calendar.getInstance();
			calendar.set(Calendar.YEAR, 1990);
			calendar.set(Calendar.DAY_OF_MONTH, 1);
			calendar.set(Calendar.MONTH, 4); // Assuming you wanted May 1st
			garante.setFechaNacimiento(new Date(calendar.getTime().getTime()));
			garante.setTelefono("233445");
			garante.setTelCelular("67233445");
			garante.setEmail("jfjdn@kfkff.com");
			garante.setOcupacion("Ciclista");
			garante.setDatosAdicionales("Tiene una bici");
			Long idGarante = reglas.insertarPersonaDB(garante);
			System.out.println("idgarante: " + idGarante);
			
		
			//Insertar credito
			Credito credito = new Credito();
			credito.setIdUsuario(idUsuario);
			calendar.set(Calendar.YEAR, 1990);
			calendar.set(Calendar.DAY_OF_MONTH, 1);
			calendar.set(Calendar.MONTH, 4); // Assuming you wanted May 1st
			credito.setFechaPrimerPago(new Date(calendar.getTime().getTime()));
			credito.setMetodoGeneracion(CUOTA_FIJA);
			credito.setMoneda(BOLIVIANOS);
			Short numeroCuotas = 10;
			credito.setNumeroCuotas(numeroCuotas);
			Short frecuenciaPagos = 1;
			credito.setFrecuenciaPagos(frecuenciaPagos);
			credito.setImporte(10450.0);
			credito.setOtrosPagos(0.0);
			credito.setInteres(31.0);
			credito.setTipoInteres(INTERES_FIJO);//Tambien puede ser variable
			credito.setCreditoActivo(true);
			Long idCredito = reglas.insertarCreditoDB(credito);
			System.out.println("idCredito: " + idCredito);

			//Insertar Personas - Creditos
			PersonaTieneCredito personaTieneCredito = new PersonaTieneCredito();
			personaTieneCredito.setIdPersona(idCliente);
			personaTieneCredito.setTipoPersona(CLIENTE);
			personaTieneCredito.setIdCredito(idCredito);
			reglas.insertarPersonaTieneCredito(personaTieneCredito);
			
			personaTieneCredito = new PersonaTieneCredito();
			personaTieneCredito.setIdPersona(idGarante);
			personaTieneCredito.setTipoPersona(GARANTE);
			personaTieneCredito.setIdCredito(idCredito);
			reglas.insertarPersonaTieneCredito(personaTieneCredito);
			
			reglas.calcularPlanPagos(idCredito, Decimales);
*/                      reglas.calcularPlanPagos(250L, Decimales);  
			
	    } catch (Exception e) {
//	    	conectionDB.rollback(connection);
	        e.printStackTrace();
	    } finally {
	    	databaseUtils.close(connection);
	    }
		
	}
	
//	private static Integer insertarPersonaTieneCredito(PersonaTieneCredito personaTieneCredito) throws SQLException {
//		Integer codigoError = 0;
//		CallableStatement callable = connection.prepareCall("{ ? = call insertar_persona_credito ( ?, ?, ?, ?) }");
//		
//		callable.registerOutParameter(1, Types.INTEGER);
//		callable.setLong(2, personaTieneCredito.getIdPersona());
//		callable.setLong(3, personaTieneCredito.getIdCredito());
//		callable.setString(4, personaTieneCredito.getTipoPersona());
//		callable.setString(5, personaTieneCredito.getDatosAdicionales());
//		callable.execute();
//		codigoError = callable.getInt(1);
//		callable.close();
//		
//		return codigoError;
//	}
//
//	private static Long insertarCreditoDB(Credito credito) throws SQLException {
//		Long idCredito = 0L;
//
//		ArrayList<String> parametros = new ArrayList<String>();
//		parametros.add(String.valueOf(credito.getIdUsuario()));
//		parametros.add(String.valueOf(credito.getFechaPrimerPago()));
//		parametros.add(String.valueOf(credito.getMetodoGeneracion()));
//		parametros.add(String.valueOf(credito.getMoneda()));
//		parametros.add(String.valueOf(credito.getNumeroCuotas()));
//		parametros.add(String.valueOf(credito.getFrecuenciaPagos()));
//		parametros.add(String.valueOf(credito.getImporte()));
//		parametros.add(String.valueOf(credito.getOtrosPagos()));
//		parametros.add(String.valueOf(credito.getInteres()));
//		parametros.add(String.valueOf(credito.getTipoInteres()));
//		parametros.add(String.valueOf(credito.getEstado()));
//		
//		idCredito = ejecutarFuncionArrayPL("insertar_credito", parametros);
//		
//		return idCredito;
//	}
//	
//	private static void calcularPlanPagos(Long idCredito) throws SQLException{
//		stmt = connection.createStatement();
//		rs = stmt.executeQuery("SELECT * FROM creditos where id_credito = " + idCredito + " and estado = true;");
//		ArrayList<ArrayList<Double>> planPagos = new ArrayList<ArrayList<Double>>();
//		ArrayList<String> fechas = new ArrayList<String>();
//		while (rs.next()){
//			Timestamp fechaRegistro = rs.getTimestamp("fecha_registro");
//			String fechaReg = rs.getString("fecha_registro");
//			String metodoGeneracion = rs.getString("metodo_generacion");
//			String moneda = rs.getString("moneda");
//			Integer num_coutas = rs.getInt("num_cuotas");
//			Integer frecuencia_pagos = rs.getInt("frecuencia_pagos");		
//			Double importeInicial = rs.getDouble("importe");
//			Double otrosPagos = rs.getDouble("otros_pagos") / num_coutas;		
//			Double interesAnual = rs.getDouble("interes");
//			Double interesMensual = interesAnual / 12;
//					
//			System.out.println("fechaRegistro: " + fechaRegistro);
//			System.out.println("fechaReg: " + fechaReg);
//			System.out.println("metodoGeneracion: " + metodoGeneracion);
//			System.out.println("moneda: " + moneda);
//			System.out.println("num_coutas: " + num_coutas);
//			System.out.println("frecuencia_pagos: " + frecuencia_pagos);
//			System.out.println("importe: " + importeInicial);
//			System.out.println("otrosPagos: " + otrosPagos);
//			System.out.println("interes: " + interesAnual);
//
//			System.out.println("fechaRegistro: " + convertDateToString(new Date(fechaRegistro.getTime())));
//			Date fechaModificada = sumarRestarMesesFecha(new Date(fechaRegistro.getTime()), 13);
//			System.out.println("fechaModificada: " + convertDateToString(fechaModificada));
//			
//			Double cuotaMensual = calcularCuotaMensual(importeInicial, interesAnual, num_coutas);
//			System.out.println("CuotaMensual: " + cuotaMensual);
//			
//			
//			// Calcular el plan de pagos
//			Double amortizacion = 0.0;
//			Double importe = 0.0;
//			Double interes = 0.0;
//			fechaModificada = sumarRestarMesesFecha(new Date(fechaRegistro.getTime()), 1);
//			for (int i = 0; i < num_coutas; i++) {
//				fechas.add(convertDateToString(sumarRestarMesesFecha(fechaModificada, i)));
//				
//				planPagos.add(new ArrayList<Double>());
//
//				importe = importeInicial - amortizacion;
//				planPagos.get(i).add(importe);
//				
//				interes = importe * interesMensual / 100;
//				planPagos.get(i).add(interes);
//				
//				amortizacion = cuotaMensual - interes;
//				planPagos.get(i).add(amortizacion);
//				importeInicial = importe;
//				
//				planPagos.get(i).add(otrosPagos);
//				planPagos.get(i).add(cuotaMensual);
//			}
//		}
//		
//		//Ensamblar y formatear el plan de pagos
//		ArrayList<ArrayList<String>> planPagosFinal =  new ArrayList<ArrayList<String>>();
//		for (int i = 0; i < planPagos.size(); i++) {
//			planPagosFinal.add(new ArrayList<String>());
//			planPagosFinal.get(i).add(fechas.get(i));
//			for (int j = 0; j < planPagos.get(i).size(); j++) {
//				planPagosFinal.get(i).add(String.format(Decimales, planPagos.get(i).get(j)));		
//			}
//		}
//		
//		//Transferir los cálculos a la base de datos
//		insertarPlanPagosDB(idCredito, planPagosFinal);
//
//	}
//
//	public static void insertarPlanPagosDB(Long idCredito, ArrayList<ArrayList<String>> planPagosFinal) throws SQLException{
//		//SELECT insertarplanpago(22, '{''24/03/2016 jue'', ''10450,00'', ''269,96'', ''929,19'', ''0'',''1199.15''}');
//		final CallableStatement callable = connection.prepareCall("{ call insertar_plan_pago ( ?, ? ) }");
//		for (int i = 0; i < planPagosFinal.size(); i++) {
//			final Array stringsArray = connection.createArrayOf("varchar", planPagosFinal.get(i).toArray(new String[planPagosFinal.get(i).size()]));
//			callable.setLong(1, idCredito);
//			callable.setArray(2, stringsArray);
//			callable.execute();
//			for (int j = 0; j < planPagosFinal.get(i).size(); j++) {
//				System.out.print("        " + planPagosFinal.get(i).get(j));
//			}
//			System.out.println(" ");
//		}
//		callable.close();
//	}
//	
//	public static Long insertarUsuarioDB(Usuario usuario) throws SQLException{
//		Long idUsuario = 0L;
//		
//		ArrayList<String> parametros = new ArrayList<String>();
//		parametros.add(String.valueOf(usuario.getCI()));
//		parametros.add(String.valueOf(usuario.getNombres()));
//		parametros.add(String.valueOf(usuario.getApPaterno()));
//		parametros.add(String.valueOf(usuario.getApMaterno()));
//		parametros.add(String.valueOf(usuario.getSexo()));
//		parametros.add(String.valueOf(usuario.getFechaNacimiento()));
//		parametros.add(String.valueOf(usuario.getTelefono()));
//		parametros.add(String.valueOf(usuario.getTelCelular()));
//		parametros.add(String.valueOf(usuario.getEmail()));
//		parametros.add(String.valueOf(usuario.getDireccion()));
//		parametros.add(String.valueOf(usuario.getCargo()));
//		
//		idUsuario = ejecutarFuncionArrayPL("insertar_usuario", parametros);
//		return idUsuario;
//	}
//
//	public static Long insertarPersonaDB(Persona persona) throws SQLException{
//		Long idPersona = 0L;
//		
//		ArrayList<String> parametros = new ArrayList<String>();
//		parametros.add(String.valueOf(persona.getCI()));
//		parametros.add(String.valueOf(persona.getNombres()));
//		parametros.add(String.valueOf(persona.getApPaterno()));
//		parametros.add(String.valueOf(persona.getApMaterno()));
//		parametros.add(String.valueOf(persona.getSexo()));
//		parametros.add(String.valueOf(persona.getFechaNacimiento()));
//		parametros.add(String.valueOf(persona.getTelefono()));
//		parametros.add(String.valueOf(persona.getTelCelular()));
//		parametros.add(String.valueOf(persona.getEmail()));
//		parametros.add(String.valueOf(persona.getDireccion()));
//		parametros.add(String.valueOf(persona.getOcupacion()));
//		
//		idPersona = ejecutarFuncionArrayPL("insertar_persona", parametros);
//		return idPersona;
//	}	
//
//	public static Long ejecutarFuncionArrayPL(String funcion,  ArrayList<String> parametros) throws SQLException {
//		Long resultado = 0L;
//		
//		CallableStatement callable = connection.prepareCall("{ ? = call " + funcion + " ( ? ) }");
//
//		callable.registerOutParameter(1, Types.BIGINT);
//		Array stringsArray = connection.createArrayOf("varchar", parametros.toArray(new String[parametros.size()]));
//		callable.setArray(2, stringsArray);
//		callable.execute();
//		resultado = callable.getLong(1);
//		callable.close();
//		
//		return resultado;
//	}
//
//	public static Double calcularCuotaMensual(Double montoPretamo, Double tasaFija, Integer numeroCuotas) {
//		Double resultado = 0.0;
//		Double c = montoPretamo;
//		Double i = tasaFija / 12; // Es anual
//		Integer n = numeroCuotas;
//		
//		resultado = (c * (i/100) * Math.pow(1 + i/100, n)) / (Math.pow(1 + i /100, n) - 1);
//		
//		return resultado;
//	}
//	
//	public static Date convertStringToDate(String dateString)
//	{
////	    Date date = null;
//	    Date formatteddate = null;
//	    DateFormat df = new SimpleDateFormat("dd/MMM/yyyy");
//	    try{
//	    	formatteddate = (Date) df.parse(dateString);
//	    }
//	    catch ( Exception ex ){
//	        System.out.println(ex);
//	    }
//	    return formatteddate;
//	}
//	
//	public static String convertDateToString(Date indate)
//	{
//	   String dateString = null;
//	   SimpleDateFormat sdfr = new SimpleDateFormat("dd/MM/yyyy EEE");
//	   /*you can also use DateFormat reference instead of SimpleDateFormat 
//	    * like this: DateFormat df = new SimpleDateFormat("dd/MMM/yyyy");
//	    */
//	   try{
//		dateString = sdfr.format( indate );
//	   }catch (Exception ex ){
//		System.out.println(ex);
//	   }
//	   return dateString;
//	}
//
//	// Suma los días recibidos a la fecha  
//	 public static Date sumarRestarMesesFecha(Date fecha, int meses){
//	      Calendar calendar = Calendar.getInstance();
//	      calendar.setTime(fecha); // Configuramos la fecha que se recibe
//	      calendar.add(Calendar.MONTH, meses);  // numero de meses a añadir, o restar en caso de meses<0
//	      if(calendar.get(Calendar.DAY_OF_WEEK) == Calendar.SUNDAY) {// Excluir domingos
//	          System.out.println("Sunday: " + calendar.getTime());
//	          calendar.add(Calendar.DAY_OF_MONTH, 1);
//	      }
//	      /*
//	      if(calendar.get(Calendar.DAY_OF_WEEK) == Calendar.SATURDAY) {// Excluir sábados
//	          System.out.println("Sunday: " + calendar.getTime());
//	          calendar.add(Calendar.DAY_OF_MONTH, 2);
//	      }*/
//	      return new Date(calendar.getTime().getTime()); // Devuelve el objeto Date connection los nuevos días añadidos
//	 }
}
