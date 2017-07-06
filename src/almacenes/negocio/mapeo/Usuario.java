package almacenes.negocio.mapeo;

public class Usuario {
    private Long idUsuario;
    private Integer CI;
    private String expCI;
    private String nombres;
    private String apPaterno;
    private String apMaterno;
    private String telefono;
    private String telCelular;
    private String email;
    private String direccion;
    private String datosAdicionales;
    private String contrasenia;
    private String nombreUsuario;
    private Integer idRol;
    private Boolean usuarioActivo;

    public Long getIdUsuario() {
        return idUsuario;
    }
    public void setIdUsuario(Long idUsuario) {
        this.idUsuario = idUsuario;
    }
    public Integer getCI() {
          return CI;
    }
    public void setCI(Integer cI) {
          CI = cI;
    }
    public String getExpCI() {
        return expCI;
    }
    public void setExpCI(String expCI) {
        this.expCI = expCI;
    }
    public String getNombres() {
          return nombres;
    }
    public void setNombres(String nombres) {
          this.nombres = nombres;
    }
    public String getApPaterno() {
          return apPaterno;
    }
    public void setApPaterno(String apPaterno) {
          this.apPaterno = apPaterno;
    }
    public String getApMaterno() {
          return apMaterno;
    }
    public void setApMaterno(String apMaterno) {
          this.apMaterno = apMaterno;
    }

    public String getTelefono() {
     return telefono;
    }

    public void setTelefono(String telefono) {
     this.telefono = telefono;
    }

    public String getTelCelular() {
     return telCelular;
    }

    public void setTelCelular(String telCelular) {
     this.telCelular = telCelular;
    }       

    public String getEmail() {
          return email;
    }
    public void setEmail(String email) {
          this.email = email;
    }
    public String getDireccion() {
          return direccion;
    }
    public void setDireccion(String direccion) {
          this.direccion = direccion;
    }

    public String getDatosAdicionales() {
    return datosAdicionales;
    }
    public void setDatosAdicionales(String datosAdicionales) {
    this.datosAdicionales = datosAdicionales;
    }
    
    public String getContrasenia() {
        return contrasenia;
    }
    public void setContrasenia(String contrasenia) {
        this.contrasenia = contrasenia;
    }

    public String getNombreUsuario() {
        return nombreUsuario;
    }
    public void setNombreUsuario(String nombreUsuario) {
        this.nombreUsuario = nombreUsuario;
    }

    public Integer getIdRol() {
        return idRol;
    }
    public void setIdRol(Integer idRol) {
        this.idRol = idRol;
    }

    public Boolean getUsuarioActivo() {
        return usuarioActivo;
    }
    public void setUsuarioActivo(Boolean usuarioActivo) {
        this.usuarioActivo = usuarioActivo;
    }
}
