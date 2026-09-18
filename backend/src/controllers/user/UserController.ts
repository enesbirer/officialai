import { Request, Response, NextFunction } from "express";
import { UserRepository } from "../../repositories/UserRepository";
import { ProfileRepository } from "../../repositories/ProfileRepository";
import { HTTP_STATUS } from "../../constants";
import { NotFoundError } from "../../utils/errors";

export class UserController {
  private userRepo: UserRepository;
  private profileRepo: ProfileRepository;

  constructor() {
    this.userRepo = new UserRepository();
    this.profileRepo = new ProfileRepository();
  }

  async getProfile(req: Request, res: Response, next: NextFunction) {
    try {
      const user = await this.userRepo.findById(req.user!.id);
      if (!user) {
        throw new NotFoundError("User not found");
      }
      res.status(HTTP_STATUS.OK).json({ success: true, data: user });
    } catch (error) {
      next(error);
    }
  }

  async updateProfile(req: Request, res: Response, next: NextFunction) {
    try {
      const { firstName, lastName, phone, language, theme, avatarUrl } = req.body;
      
      const profile = await this.profileRepo.findByUserId(req.user!.id);
      if (!profile) {
        await this.profileRepo.create({
          user: { connect: { id: req.user!.id } },
          firstName,
          lastName,
          phone,
          language,
          theme,
          avatarUrl,
        });
      } else {
        await this.profileRepo.update(req.user!.id, {
          firstName,
          lastName,
          phone,
          language,
          theme,
          avatarUrl,
        });
      }
      
      const updatedUser = await this.userRepo.findById(req.user!.id);
      res.status(HTTP_STATUS.OK).json({ success: true, data: updatedUser });
    } catch (error) {
      next(error);
    }
  }
}
