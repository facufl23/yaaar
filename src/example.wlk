class Pirata {
	
	var property items = #{}
	var property nivelEbriedad
	var property dinero
	var property invitados
	
	method esUtil(mision){
		return mision.esUtil(self)
	}
	method tieneItem(item) {
		return items.contains(item)
	}
	method tieneAlgunItem() {
		return self.tieneItem("brujula") || self.tieneItem("mapa") || self.tieneItem("grogXD")
	}
	method tieneMasDeCincoMonedas() {
		return dinero > 5
	}
	method tieneLlaveDeCofre() {
		return self.tieneItem("llave")
	}
	method puedeEstarEn(barco) {
		return barco.tieneLugar() && self.esUtil(barco.mision())
	}
	method aumentarEbriedad(cantidad) {
		nivelEbriedad += cantidad
	}
	method gastarMonedas(cantidad) {
		dinero -= cantidad
	}
	method tomarTragoGrogXD() {
		self.aumentarEbriedad(5)
		self.gastarMonedas(1)
	}
	method tieneAlMenos10Items() {
		return self.cantidadItems() >= 10
	}
	method tieneMenosDineroQue(cantidad) {
		return dinero < cantidad
	}
	method tieneMasEbriedadQue(cantidad) {
		return nivelEbriedad >= cantidad
	}
	method estaPasadoDeGrogXD() {
		return self.tieneMasEbriedadQue(90)
	}
	method seAnimaASaquearCiudad() {
		return self.tieneMasEbriedadQue(50)
	}
	method seAnimaASaquearBarco() {
		return self.estaPasadoDeGrogXD()
	}
	method cantidadItems() {
		return items.size()
	}
	method invitarA(pirata,barco) {
		barco.aceptarInvitacion(self,pirata)
	}
	method sumarInvitado() {
		invitados += 1
	}
}

class PirataEspia inherits Pirata {
	override method estaPasadoDeGrogXD() {
		return false
	}
	override method seAnimaASaquearBarco() {
		super()
		return self.tieneItem("permiso de la corona")
	}
	override method seAnimaASaquearCiudad() {
		super()
		return self.tieneItem("permiso de la corona")
	}
}

class Barco {
	
	var property mision
	var tripulantes = #{}
	const capacidad
	
	method aceptarInvitacion(pirata, otroPirata) {
		if (self.tieneTripulante(pirata)) {
			self.incorporarPirata(otroPirata)
			pirata.sumarInvitado()
		} else {
			throw new Exception(message = "El pirata no puede invitar porque no esta")
		}
	}
	method tripulanteQueMasInvito() {
		return tripulantes.max({tripulante=>tripulante.invitados()})
	}
	method tieneTripulante(pirata) {
		return tripulantes.contains(pirata)
	}
	method tieneLugar() {
		return self.cantidadDeTripulantes() < capacidad
	}
	
	method incorporarPirata(pirata) {
		if (self.tieneLugar() && pirata.puedeEstarEn(self)) {
			tripulantes.add(pirata)
		} else {
			throw new Exception(message="No hay mas lugar en el barco")
		}
	}
	method destituirPirata(pirata) {
		tripulantes.remove(pirata)
	}
	method pirataMasEbrio() {
		return tripulantes.max({tripulante=>tripulante.nivelEbriedad()})
	}
	
	method anclarEnCiudadCostera(ciudad) {
		tripulantes.forEach({tripulante=>tripulante.tomarTragoGrogXD()})
		self.destituirPirata(self.pirataMasEbrio())
		ciudad.aumentarHabitantes(1)
	}
	
	method cambiarMision(misionNueva) {
		self.mision(misionNueva)
		tripulantes.filter({tripulante=>tripulante.esUtil(mision)})
	}
	
	method alguienTieneLlave() {
		return tripulantes.any({pirata=>pirata.tieneLlaveDeCofre()})
	}
	method esTemible() {
		return mision.puedeSerRealizada(self)
	}
	method tieneSuficienteTripulacion() {
		return tripulantes.size() >= capacidad*0.9
	}
	method cantidadDeTripulantes() {
		return tripulantes.size()
	}
	method esVulnerable(barco) {
		return (self.cantidadDeTripulantes()).div(2) <= barco.cantidadDeTripulantes()
	}
	method todosPasados() {
		return tripulantes.all({tripulante=>tripulante.estaPasadoDeGrogXD()})
	}
	method cantidadDeTripulantesPasados() {
		return tripulantes.count({tripulante=>tripulante.estaPasadoDeGrogXD()})
	}
	method tripulantesPasados() {
		return tripulantes.filter({tripulante=>tripulante.estaPasadoDeGrogXD()})
	}
	method itemsDePasados() {
		return self.tripulantesPasados().map({tripulante=>tripulante.items()})
	}
	method itemsDePasadosSinRepetir() {
		return self.itemsDePasados().asSet()
	}
	method cantidadDeItemsDePasadosSinRepetir() {
		return self.itemsDePasadosSinRepetir().size()
	}
	method tripulantePasadoConMasDinero() {
		self.tripulantesPasados().max({tripulante=>tripulante.dinero()})
	}
}

class BusquedaDelTesoro {
	
	method esUtil(pirata) {
		return pirata.tieneAlgunItem() && not(pirata.tieneMasDeCincoMonedas())
	}
	method puedeSerRealizada(barco) {
		return barco.alguienTieneLlave()
	}
}

class ConvertirseEnLeyenda {
	const itemObligatorio
	
	method esUtil(pirata) {
		return pirata.tieneAlMenos10Items() && pirata.tieneItem(itemObligatorio)
	}
	method puedeSerRealizada(barco) {
		return true
	}
}

class Saqueo {
	
	var cantidadDinero
	const victima
	
	method esUtil(pirata) {
		return pirata.tieneMenosDineroQue(cantidadDinero)
	}
	method puedeSerRealizada(barco) {
		return victima.esVulnerable(barco)
	}
}

class SaqueoBarco inherits Saqueo {
	override method esUtil(pirata) {
		super(pirata)
		return pirata.seAnimaASaquearBarco()
	}
	
}

class SaqueoCiudad inherits Saqueo {
	override method esUtil(pirata) {
		super(pirata)
		return pirata.seAnimaASaquearCiudad()
	}
	
}

class Ciudad {
	var habitantes
	method esVulnerable(barco) {
		return barco.cantidadDeTripulantes() >= 0.4*habitantes || barco.todosPasados()
	}
	method aumentarHabitantes(cantidad) {
		habitantes += cantidad
	}
}


