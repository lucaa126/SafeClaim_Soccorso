import { Injectable, Renderer2, RendererFactory2 } from '@angular/core';
import { BehaviorSubject } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class ThemeService {
  private renderer: Renderer2;
  private isDarkModeSubject = new BehaviorSubject<boolean>(false);
  public isDarkMode$ = this.isDarkModeSubject.asObservable();

  constructor(rendererFactory: RendererFactory2) {
    this.renderer = rendererFactory.createRenderer(null, null);
    this.loadTheme();
  }

  private loadTheme(): void {
    const savedTheme = localStorage.getItem('theme');
    const prefersDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
    const isDark = savedTheme ? savedTheme === 'dark' : prefersDark;
    this.setDarkMode(isDark);
  }

  toggleDarkMode(): void {
    const current = this.isDarkModeSubject.value;
    this.setDarkMode(!current);
  }

  private setDarkMode(isDark: boolean): void {
    this.isDarkModeSubject.next(isDark);
    const body = document.body;
    if (isDark) {
      this.renderer.addClass(body, 'dark-theme-variables');
    } else {
      this.renderer.removeClass(body, 'dark-theme-variables');
    }
    localStorage.setItem('theme', isDark ? 'dark' : 'light');
  }

  get isDarkMode(): boolean {
    return this.isDarkModeSubject.value;
  }
}