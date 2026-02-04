import { Component, OnInit, ViewEncapsulation } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';
import { HttpClientModule } from '@angular/common/http';
import { ThemeService } from '../theme.service';

@Component({
  selector: 'app-settings',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule, HttpClientModule],
  templateUrl: './settings.html',
  styleUrl: './settings.css',
  encapsulation: ViewEncapsulation.None
})
export class Settings implements OnInit {

  // UI State
  isSidebarOpen: boolean = false;
  workshopName: string = 'Officina Centrale';
  
  // Settings State
  workshopEmail: string = 'officina@example.com';
  workshopPhone: string = '+39 02 1234567';
  workshopAddress: string = 'Via Roma 123, Milano';
  notificationsEnabled: boolean = true;
  emailNotifications: boolean = true;
  smsNotifications: boolean = false;
  maxRequests: number = 10;
  workingHours: string = '08:00-20:00';
  autoAcceptRequests: boolean = false;

  constructor(private themeService: ThemeService) {}

  ngOnInit(): void {
    // Tema gestito dal servizio
  }

  toggleDarkMode(): void {
    this.themeService.toggleDarkMode();
  }

  get isDarkMode(): boolean {
    return this.themeService.isDarkMode;
  }

  openMenu(): void {
    this.isSidebarOpen = !this.isSidebarOpen;
  }

  saveSettings(): void {
    console.log('Impostazioni salvate:', {
      workshopName: this.workshopName,
      workshopEmail: this.workshopEmail,
      workshopPhone: this.workshopPhone,
      workshopAddress: this.workshopAddress,
      notificationsEnabled: this.notificationsEnabled,
      emailNotifications: this.emailNotifications,
      smsNotifications: this.smsNotifications,
      maxRequests: this.maxRequests,
      workingHours: this.workingHours,
      autoAcceptRequests: this.autoAcceptRequests
    });
    alert('Impostazioni salvate con successo!');
  }

  resetSettings(): void {
    if (confirm('Sei sicuro di voler resettare tutte le impostazioni?')) {
      this.workshopName = 'Officina Centrale';
      this.workshopEmail = 'officina@example.com';
      this.workshopPhone = '+39 02 1234567';
      this.workshopAddress = 'Via Roma 123, Milano';
      this.notificationsEnabled = true;
      this.emailNotifications = true;
      this.smsNotifications = false;
      this.maxRequests = 10;
      this.workingHours = '08:00-20:00';
      this.autoAcceptRequests = false;
    }
  }

  logout(): void {
    console.log('Logout eseguito');
    // Logica di logout qui
  }
}
