const mongoose = require('mongoose');
const bcyrpt = require('bcrypt');
const UserSchema = new mongoose.Schema({
    userId: { type: String, required: true, unique: true },
    username:{type:String, required:true, unique:true},
    password: { type: String, required: true },
    
    role: { type: String, enum: ['admin', 'worker'], default: 'worker', required: true },
    assignedAnganwadiCode: { type: String, required:function(){return this.role === 'worker';}, default: null },
    isActive: { type: Boolean, default: true },
    lastLogin: { type: Date, default: Date.now },
    createdAt: { type: Date, default: Date.now }
});

UserSchema.pre('save', async function(next){
    if(!this.isModified('password')){
        return next();
    }
    try{
        const salt=await bcyrpt.genSalt(10);
        this.password=await bcyrpt.hash(this.password,salt);
        next();

    }
    catch(err){
        next(err);
    }
})
UserSchema.methods.comparePassword= async function(candidatePassword){
    return await bcyrpt.compare(candidatePassword, this.password);

}

module.exports = mongoose.model('User', UserSchema);