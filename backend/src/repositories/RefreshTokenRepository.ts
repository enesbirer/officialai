import prisma from "../config/prisma";
import { RefreshToken, Prisma } from "@prisma/client";

export class RefreshTokenRepository {
  async create(data: Prisma.RefreshTokenCreateInput): Promise<RefreshToken> {
    return prisma.refreshToken.create({ data, include: { user: true } });
  }

  async findByToken(token: string): Promise<(RefreshToken & { user: any }) | null> {
    return prisma.refreshToken.findUnique({ where: { token }, include: { user: true } });
  }

  async deleteByUserId(userId: string): Promise<void> {
    await prisma.refreshToken.deleteMany({ where: { userId } });
  }

  async deleteByToken(token: string): Promise<void> {
    await prisma.refreshToken.delete({ where: { token } });
  }
}
