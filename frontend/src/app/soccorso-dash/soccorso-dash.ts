import { Component, OnInit, Renderer2, ViewEncapsulation } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';

@Component({
  selector: 'app-soccorso-dash',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule],
  templateUrl: './soccorso-dash.html',
  styleUrl: './soccorso-dash.css',
  encapsulation: ViewEncapsulation.None
})
export class SoccorsoDash implements OnInit {

  isSidebarOpen: boolean = false;
  isDarkMode: boolean = false;
  acceptingSoccorsi: boolean = true;
  workshopName: string = 'Officina Centrale';
  
  requests: Array<any> = [];
  selectedRequest: any = null;

  constructor(private renderer: Renderer2) {}

  ngOnInit(): void {
    // Check system preference for dark mode
    if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
      this.toggleDarkMode();
    }
    this.loadRequests();
  }

  // UI ACTIONS
  openMenu(): void { this.isSidebarOpen = true; }
  closeMenu(): void { this.isSidebarOpen = false; }

  toggleDarkMode(): void {
    this.isDarkMode = !this.isDarkMode;
    const body = document.body;
    if (this.isDarkMode) {
      this.renderer.addClass(body, 'dark-theme-variables');
    } else {
      this.renderer.removeClass(body, 'dark-theme-variables');
    }
  }

  logout(): void {
    // Logic for logout
    console.log("Logout triggered");
  }

  toggleSoccorsi(): void {
    this.acceptingSoccorsi = !this.acceptingSoccorsi;
  }

  // DATA MOCKING
  loadRequests(): void {
    this.requests = [
      {
        id: 'SOS-2491',
        time: new Date(),
        vehicleType: 'Fiat Ducato (Furgone)',
        contact: '+39 333 1234567',
        status: null, // null = pending
        lat: 45.4642, lng: 9.1900
      },
      {
        id: 'SOS-2492',
        time: new Date(Date.now() - 1000 * 60 * 15),
        vehicleType: 'BMW X3 (SUV)',
        contact: '+39 338 9876543',
        status: 'accepted',
        lat: 45.4700, lng: 9.1800
      },
      {
        id: 'SOS-2488',
        time: new Date(Date.now() - 1000 * 60 * 120),
        vehicleType: 'Smart ForTwo',
        contact: '+39 339 0000000',
        status: 'handled',
        lat: 45.4500, lng: 9.2000
      }
    ];
    // Seleziona il primo se disponibile
    if (this.requests.length > 0) {
      this.selectedRequest = this.requests[0];
    }
  }

  selectRequest(req: any): void {
    this.selectedRequest = req;
    // Su mobile potresti voler scrollare alla sezione dettagli o aprire una modale
  }

  acceptRequest(req: any): void {
    req.status = 'accepted';
    // Sposta logica API qui
  }

  declineRequest(req: any): void {
    this.requests = this.requests.filter(x => x.id !== req.id);
    this.selectedRequest = this.requests[0] || null;
  }

  markHandled(req: any): void {
    req.status = 'handled';
    // Sposta nello storico o rimuovi
    setTimeout(() => {
        this.requests = this.requests.filter(x => x.id !== req.id);
        if(this.selectedRequest?.id === req.id) this.selectedRequest = this.requests[0] || null;
    }, 1000);
  }
}