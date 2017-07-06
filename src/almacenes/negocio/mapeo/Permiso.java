/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package almacenes.negocio.mapeo;

/**
 *
 * @author georgeguitar
 */
public class Permiso {
  Integer idPermiso;
  String nombrePermiso;

    public Integer getIdPermiso() {
        return idPermiso;
    }
    public void setIdPermiso(Integer idPermiso) {
        this.idPermiso = idPermiso;
    }

    public String getNombrePermiso() {
        return nombrePermiso;
    }
    public void setNombrePermiso(String nombrePermiso) {
        this.nombrePermiso = nombrePermiso;
    }
}
