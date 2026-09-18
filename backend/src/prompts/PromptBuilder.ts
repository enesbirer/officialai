export class PromptBuilder {
  private systemPrompt: string = "";
  private userPrompt: string = "";
  private safetyRules: string[] = [];
  private contextNotes: string[] = [];

  setSystemPrompt(prompt: string): PromptBuilder {
    this.systemPrompt = prompt;
    return this;
  }

  setUserPrompt(prompt: string): PromptBuilder {
    this.userPrompt = prompt;
    return this;
  }

  addSafetyRule(rule: string): PromptBuilder {
    this.safetyRules.push(rule);
    return this;
  }

  addContextNote(note: string): PromptBuilder {
    this.contextNotes.push(note);
    return this;
  }

  addPetitionCategory(categoryName: string, categoryFields: Record<string, string>): PromptBuilder {
    this.contextNotes.push(`Dilekçe Kategorisi: ${categoryName}`);
    this.contextNotes.push(`Kategoriye Özel Alanlar: ${JSON.stringify(categoryFields)}`);
    return this;
  }

  setChatHistory(messages: Array<{ role: string; content: string }>): PromptBuilder {
    this.contextNotes.push(`Önceki Sohbet Geçmişi (en eski en başta olacak şekilde):\n${messages.map(m => `[${m.role.toUpperCase()}]: ${m.content}`).join("\n")}`);
    return this;
  }

  build(): { systemPrompt: string; userPrompt: string } {
    let finalSystem = this.systemPrompt;

    if (this.contextNotes.length > 0) {
      finalSystem += `\n\n=== BAĞLAM BİLGİLERİ ===\n${this.contextNotes.join("\n")}`;
    }

    if (this.safetyRules.length > 0) {
      finalSystem += `\n\n=== GÜVENLİK KURALLARI ===\n${this.safetyRules.map((r, i) => `${i + 1}. ${r}`).join("\n")}`;
    }

    finalSystem += `\n\n=== ÖZEL TALİMAT ===
- KULLANICIYA YARDIMCI OL, AÇIKLAYICI YANIT VER
- YANITLARINI BİçİNDEKİ YAPISAL ETİKETLERİ (=== BAŞLIK GİBİ) KORU AMA DAHA OKUNABİLİR HALE GETİR
- EKSİK BİLGİLER İÇİN MAKUL VARSAYIMLAR YAP, [BELİRTİNİZ] ETİKETİYLE İŞARETLE
- TÜRKÇE KARAKTERLERİ (ğşıüöç) DOĞRU KULLAN`;

    return { systemPrompt: finalSystem, userPrompt: this.userPrompt };
  }
}
