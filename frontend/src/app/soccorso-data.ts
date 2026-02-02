import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs';

// --- DEFINIZIONE DEI MODELLI DEI DATI ---

export interface Request {
  id: string;
  time: Date;
  vehicleType: string;
  contact: string;
  // Status: null = in attesa, 'accepted' = in corso, 'handled' = completato
  status: 'pending' | 'accepted' | 'handled' | null; 
  lat: number;
  lng: number;
  assignedDriver?: string; // Chi lo sta soccorrendo
  notes?: string;
}

export interface Vehicle {
  id: string;
  name: string;
  plate: string; // Targa
  status: 'available' | 'busy' | 'maintenance';
  driver: string;
  lat: number;
  lng: number;
  currentTask?: string; // ID della richiesta che sta gestendo
}

@Injectable({
  providedIn: 'root',
})
export class SoccorsoData {

  // --- DATI FINTI INIZIALI (MOCK) ---
  
  private initialRequests: Request[] = [
    { 
      id: 'SOS-2491', 
      time: new Date(), 
      vehicleType: 'Fiat Ducato (Furgone)', 
      contact: '+39 333 1234567', 
      status: null, // In attesa
      lat: 45.4642, 
      lng: 9.1900 
    },
    { 
      id: 'SOS-2492', 
      time: new Date(Date.now() - 1000 * 60 * 15), // 15 min fa
      vehicleType: 'BMW X3 (SUV)', 
      contact: '+39 338 9876543', 
      status: 'accepted', 
      assignedDriver: 'Mario Rossi',
      lat: 45.4780, 
      lng: 9.1240 
    },
    { 
      id: 'SOS-2488', 
      time: new Date(Date.now() - 1000 * 60 * 120), // 2 ore fa
      vehicleType: 'Smart ForTwo', 
      contact: '+39 339 0000000', 
      status: 'handled', 
      assignedDriver: 'Luca Bianchi',
      lat: 45.4500, 
      lng: 9.2000 
    }
  ];

  private initialFleet: Vehicle[] = [
    { id: 'V-01', name: 'Carroattrezzi A (Pianale)', plate: 'GA 123 AB', status: 'available', driver: 'Mario Rossi', lat: 45.4600, lng: 9.1800 },
    { id: 'V-02', name: 'Carroattrezzi B (Gru)', plate: 'FF 987 KK', status: 'busy', driver: 'Luca Bianchi', currentTask: 'SOS-2492', lat: 45.4780, lng: 9.1240 },
    { id: 'V-03', name: 'Furgone Officina', plate: 'DZ 456 YY', status: 'maintenance', driver: 'Giuseppe Verdi', lat: 45.4500, lng: 9.1500 }
  ];

  // --- GESTIONE DELLO STATO (RXJS) ---
  // BehaviorSubject mantiene l'ultimo valore e lo invia a chiunque si iscriva

  private requestsSubject = new BehaviorSubject<Request[]>(this.initialRequests);
  public requests$ = this.requestsSubject.asObservable();

  private fleetSubject = new BehaviorSubject<Vehicle[]>(this.initialFleet);
  public fleet$ = this.fleetSubject.asObservable();

  constructor() { }

  // --- METODI PER MODIFICARE I DATI ---

  // Aggiorna lo stato di una richiesta (es. da Pending a Accepted)
  updateRequestStatus(id: string, status: 'pending' | 'accepted' | 'handled' | null, driverName?: string) {
    const currentData = this.requestsSubject.value; // Prendi i dati attuali
    const index = currentData.findIndex(r => r.id === id); // Trova l'indice
    
    if (index !== -1) {
      // Aggiorna i campi
      currentData[index].status = status;
      if (driverName) {
        currentData[index].assignedDriver = driverName;
      }
      // Emetti i nuovi dati a tutti i componenti
      this.requestsSubject.next([...currentData]); 
    }
  }

  // Elimina una richiesta
  deleteRequest(id: string) {
    const currentData = this.requestsSubject.value;
    const updatedData = currentData.filter(r => r.id !== id);
    this.requestsSubject.next(updatedData);
  }

  // Aggiunge una nuova richiesta (utile per test futuri)
  addRequest(newReq: Request) {
    const currentData = this.requestsSubject.value;
    this.requestsSubject.next([newReq, ...currentData]);
  }

  // Metodo helper per ottenere statistiche veloci
  getStats() {
    const reqs = this.requestsSubject.value;
    return {
      total: reqs.length,
      active: reqs.filter(r => !r.status || r.status === 'accepted').length,
      completed: reqs.filter(r => r.status === 'handled').length,
      pending: reqs.filter(r => !r.status).length
    };
  }
}